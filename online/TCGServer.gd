extends Node

class_name TCGServer

enum MessageType {
	PING = -1,
	NONE = 0,
	QUEUE = 1,
	START_GAME = 2,
	DECK = 3,
	EVENT = 4,
	ACTION = 5,
	IDENTITY = 6,
	USERNAME = 7,
	ROOM_LIST = 8,
	HOST_ROOM = 9,
	JOIN_ROOM = 10,
	COUNTDOWN = 11,
	UNREADY = 12,
	CHAT = 20,
	OK = 200,
	DENIED = 400,
	ERROR = 500
}

enum ClientState {
	IDLE = 1,
	AWAIT_NAME = 2,
	IN_ROOM = 3,
	READY = 4,
	PLAYING = 5
}

const PORT = 5310

var tcp_server = TCPServer.new()
var game_tscn = preload("res://scenes/game_board.tscn")
var rooms: Array[ServerRoom] = []
var peer_to_room: Dictionary = {}
var clients: Dictionary = {}
var queue: Array

func log_message(message: String) -> void:
	var time := "[%s]" % Time.get_time_string_from_system()
	print(time, " ", message)

func _ready() -> void:
	if tcp_server.listen(PORT) != OK:
		log_message("Unable to start server. Failed to listen to port.")
		set_process(false)

func _process(delta: float) -> void:
	while tcp_server.is_connection_available():
		var conn: StreamPeerTCP = tcp_server.take_connection()
		assert(conn != null)
		var peer: WebSocketPeer = WebSocketPeer.new()
		peer.accept_stream(conn)
		clients[peer] = ServerPeer.new(peer)
		Logger.i("Got new connection from %s" % peer.get_connected_host())
	
	for peer in clients:
		var client = clients[peer]
		peer.poll()
		if peer.get_ready_state() == WebSocketPeer.STATE_OPEN:
			client.ping_timer += delta
			if client.ping_timer >= 5:
				ping(peer)
				client.ping_timer = 0
			while peer.get_available_packet_count():
				handle_packet(peer)

	for room in rooms:
		var old_countdown: float = room.countdown
		room.update(delta)
		if old_countdown != 5 and room.countdown == 5:
			for p in room.get_players():
				send_countdown(-1, p.peer)
		elif room.countdown < 0 and old_countdown >= 0:
			start_game(room)
		elif floor(old_countdown) != floor(room.countdown):
			for p in room.get_players():
				send_countdown(ceil(room.countdown), p.peer)

func handle_packet(peer: WebSocketPeer):
	var msg_data: PackedByteArray = peer.get_packet()
	var msg: PackedInt32Array = msg_data.to_int32_array()
	var type: MessageType = msg[0]
	match type:
		MessageType.PING:
			clients[peer].last_ping = Time.get_unix_time_from_system()
		MessageType.CHAT:
			var msg_text: String = msg.slice(1).to_byte_array().get_string_from_utf8()
			Logger.i("Sending chat: " + msg_text)
			send_chat(peer, msg_text)
		MessageType.ACTION:
			var msg_text: String = msg.slice(1).to_byte_array().get_string_from_ascii()
			if peer in peer_to_room:
				var game: ServerRoom = peer_to_room[peer]
				if game.game_board == null:
					Logger.w("Got action for room without a game_board")
					return
				if peer == game.p1.peer:
					Logger.i("Got action for P1: %s" % msg_text)
					var valid: int = verify_action(msg_text)
					if valid == 1:
						Logger.w("Invalid actions")
						return
					elif valid == 2:
						game.game_board.end_game(Enum.GameResult.P1_FORFEIT)
						return
					game.actions[0].push_back(msg_text)
				elif peer == game.p2.peer:
					Logger.i("Got action for P2: %s" % msg_text)
					var valid: int = verify_action(msg_text)
					if valid == 1:
						Logger.w("Invalid actions")
						return
					elif valid == 2:
						game.game_board.end_game(Enum.GameResult.P2_FORFEIT)
						return
					game.actions[1].push_back(msg_text)
		MessageType.USERNAME:
			if clients[peer].state != ClientState.AWAIT_NAME:
				return
			var username: String = msg.slice(1).to_byte_array().get_string_from_utf8()
			if not ServerPeer.verify_name(username):
				Logger.i("Denied username: " + username)
				send_denied(peer)
				return
			Logger.i("Got username: " + username)
			clients[peer].name = username
			clients[peer].state = ClientState.IDLE
			send_ok(peer)
			send_rooms(peer)
		MessageType.ROOM_LIST:
			Logger.i("Sent rooms for refresh")
			send_rooms(peer)
		MessageType.HOST_ROOM:
			var room_info: PackedStringArray = msg.slice(1).to_byte_array().get_string_from_utf8().split("\t")
			Logger.i("Got room host info: " + str(room_info))
			if not ServerRoom.verify_args(room_info):
				Logger.w("Room info invalid")
				send_denied(peer)
				return
			if peer in peer_to_room:
				Logger.w("Client is already in a room")
				send_denied(peer)
				return
			var room: ServerRoom = ServerRoom.new()
			room.id = ServerRoom.get_next_id()
			room.name = room_info[0]
			room.p1_name = clients[peer].name
			room.p1 = clients[peer]
			room.password = room_info[1]
			room.ruleset = int(room_info[2])
			rooms.push_back(room)
			peer_to_room[peer] = room
			send_room(room, peer)
			clients[peer].state = ClientState.IN_ROOM
		MessageType.JOIN_ROOM:
			var room_id: int = msg[1]
			if room_id == -1:
				# Leave room
				if peer not in peer_to_room:
					Logger.w("Client tried to leave room while not in a room")
					return
				if clients[peer].state == ClientState.PLAYING:
					Logger.w("Cannot leave room while playing")
					return
				var room: ServerRoom = peer_to_room[peer]
				room.remove_player(clients[peer])
				peer_to_room.erase(peer)
				for p in room.get_players():
					if p != null:
						send_room(room, p.peer)
				clients[peer].state = ClientState.IDLE
				if room.p1 == null and room.p2 == null:
					Logger.i("Room closed")
					rooms.erase(room)
				return
			var room: ServerRoom = get_room(room_id)
			var password: String = msg.slice(2).to_byte_array().get_string_from_utf8()
			if room == null:
				Logger.w("Client tried to join a room that doesn't exist")
				send_denied(peer)
				return
			if room.p1 != null and room.p2 != null:
				Logger.w("Client tried to join a full room")
				send_denied(peer)
				return
			if room.password != password:
				Logger.w("Client input the incorrect password")
				send_denied(peer)
				return
			if room.p1 == null:
				room.p1 = clients[peer]
				room.p1_name = clients[peer].name
			elif room.p2 == null:
				room.p2 = clients[peer]
				room.p2_name = clients[peer].name
			peer_to_room[peer] = room
			for p in room.get_players():
				if p != null:
					send_room(room, p.peer)
			clients[peer].state = ClientState.IN_ROOM
			Logger.i("Client joined room " + str(room_id))
		MessageType.DECK:
			if not clients[peer].is_in_room() or peer not in peer_to_room:
				Logger.w("Client sent deck when not in a room")
				send_denied(peer)
				return
			var card_ids: PackedStringArray = msg.slice(1).to_byte_array().get_string_from_ascii().split(",")
			Logger.i("Got deck: " + ",".join(card_ids))
			var room = peer_to_room[peer]
			if Rulesets.verify_deck(room.ruleset, card_ids) == 0:
				Logger.i("Deck OK!")
				if room.p1 == clients[peer]:
					room.p1_deck = card_ids
				elif room.p2 == clients[peer]:
					room.p2_deck = card_ids
				else:
					Logger.w("Player was not in room they sent a deck to")
					send_denied(peer)
					return
				send_ok(peer)
				clients[peer].state = ClientState.READY
				for p in room.get_players():
					if p != null:
						send_room(room, p.peer)
			else:
				Logger.w("Invalid deck")
				send_denied(peer)
		MessageType.UNREADY:
			if not clients[peer].is_in_room() or peer not in peer_to_room:
				Logger.w("Client unreadied when not in a room")
				send_denied(peer)
				return
			var room = peer_to_room[peer]
			if room.p1 == clients[peer]:
				room.p1_deck = []
			elif room.p2 == clients[peer]:
				room.p2_deck = []
			else:
				Logger.w("Player was not in room they unreadied from")
				send_denied(peer)
				return
			send_ok(peer)
			clients[peer].state = ClientState.IN_ROOM
			for p in room.get_players():
				if p != null:
					send_room(room, p.peer)

func get_room(id: int) -> ServerRoom:
	for room in rooms:
		if room.id == id:
			return room
	return null

func start_game(room: ServerRoom):
	var game: Dictionary = {
		"players": [room.p1.peer, room.p2.peer],
		"decks": [null, null],
		"actions": [[], []]
	}
	var game_scene = game_tscn.instantiate()
	game_scene.player_options.push_back({
		"deck": {
			"cards": room.p1_deck
		},
		"ai": false,
		"peer": room.p1.peer
	})
	game_scene.player_options.push_back({
		"deck": {
			"cards": room.p2_deck
		},
		"ai": false,
		"peer": room.p2.peer
	})
	game_scene.game_options["reveal_hands"] = false
	game_scene.game_options["online"] = "server"
	game_scene.server = self
	add_child(game_scene)
	room.game_board = game_scene
	var msg: PackedInt32Array
	msg.append(MessageType.START_GAME)
	room.p1.peer.send(msg.to_byte_array())
	room.p2.peer.send(msg.to_byte_array())
	Logger.i("Started match")
	room.p1_deck = []
	room.p2_deck = []
	send_room(room, room.p1.peer)
	send_room(room, room.p2.peer)

func send_chat(peer: WebSocketPeer, message: String) -> void:
	if peer in peer_to_room:
		var type: PackedInt32Array
		type.append(MessageType.CHAT)
		for player: WebSocketPeer in peer_to_room[peer]["players"]:
			if player != peer:
				player.send(type.to_byte_array() + message.to_utf8_buffer())

func send_ok(peer: WebSocketPeer) -> void:
	var msg: PackedInt32Array
	msg.append(MessageType.OK)
	peer.send(msg.to_byte_array())

func send_denied(peer: WebSocketPeer) -> void:
	var msg: PackedInt32Array
	msg.append(MessageType.DENIED)
	peer.send(msg.to_byte_array())

func send_rooms(peer: WebSocketPeer) -> void:
	var type: PackedInt32Array
	type.append(MessageType.ROOM_LIST)
	var room_str: String = str(len(rooms))
	for room: ServerRoom in rooms:
		# Do not show rooms that are empty or full
		if (room.p1 == null) == (room.p2 == null):
			continue
		room_str += "\n"
		room_str += room.to_str()
	var msg_data = type.to_byte_array() + room_str.to_utf8_buffer()
	while msg_data.size() % 4 != 0:
		msg_data.push_back(0)
	peer.send(msg_data)

func send_room(room: ServerRoom, peer: WebSocketPeer) -> void:
	var type: PackedInt32Array
	type.append(MessageType.JOIN_ROOM)
	var room_str: String = room.to_str()
	var msg_data = type.to_byte_array() + room_str.to_utf8_buffer()
	while msg_data.size() % 4 != 0:
		msg_data.push_back(0)
	peer.send(msg_data)

func send_countdown(value: int, peer: WebSocketPeer) -> void:
	var type: PackedInt32Array
	type.append(MessageType.COUNTDOWN)
	type.append(value)
	peer.send(type.to_byte_array())

func verify_action(msg_text: String) -> int:
	var params: PackedStringArray = msg_text.split("\t")
	var action: int = int(params[0])
	if action < 1 and action > 13:
		return 1
	if action == Controller.Action.FORFEIT:
		return 2
	return 0

func ping(peer: WebSocketPeer) -> void:
	var type: PackedInt32Array
	type.push_back(MessageType.PING)
	peer.send(type.to_byte_array())

func _exit_tree() -> void:
	for peer in clients:
		peer.close()
	tcp_server.stop()

func end_board(board: GameBoard) -> void:
	board.queue_free()
	remove_child(board)
