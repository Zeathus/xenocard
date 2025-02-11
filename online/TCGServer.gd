extends Node

class_name TCGServer

enum MessageType {
	NONE = 0,
	QUEUE = 1,
	MATCHED = 2,
	DECK = 3,
	EVENT = 4,
	ACTION = 5,
	IDENTITY = 6,
	USERNAME = 7,
	ROOM_LIST = 8,
	HOST_ROOM = 9,
	JOIN_ROOM = 10,
	CHAT = 20,
	OK = 200,
	DENIED = 400,
	ERROR = 500
}

enum ClientState {
	IDLE = 1,
	QUEUING = 2,
	AWAIT_DECK = 3,
	AWAIT_NAME = 4
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
		peer.poll()
		if peer.get_ready_state() == WebSocketPeer.STATE_OPEN:
			while peer.get_available_packet_count():
				handle_packet(peer)
	
	#if len(queue) >= 2:
		#for i in range(queue.size() - 1):
			#for j in range(i + 1, queue.size()):
				#if clients[queue[i]]["password"] == clients[queue[j]]["password"]:
					#Logger.i("We found a match!")
					#prepare_match(queue[i], queue[j])
					#queue.erase(queue[j])
					#queue.erase(queue[i])
					#return

func handle_packet(peer: WebSocketPeer):
	var msg_data: PackedByteArray = peer.get_packet()
	var msg: PackedInt32Array = msg_data.to_int32_array()
	var type: MessageType = msg[0]
	match type:
		MessageType.QUEUE:
			if clients[peer].state != ClientState.IDLE:
				Logger.w("Deny queue request")
				pass # Deny the connection
			else:
				Logger.i("Client " + peer.get_connected_host() + " queued")
				clients[peer].state = ClientState.QUEUING
				queue.push_back(peer)
				send_ok(peer)
		MessageType.CHAT:
			var msg_text: String = msg.slice(1).to_byte_array().get_string_from_utf8()
			print("Sending chat: ", msg_text)
			send_chat(peer, msg_text)
		MessageType.DECK:
			if clients[peer].state != ClientState.AWAIT_DECK or peer not in peer_to_room:
				return
			var card_ids: PackedStringArray = msg.slice(1).to_byte_array().get_string_from_ascii().split(",")
			if verify_deck(card_ids) == 0:
				Logger.i("Deck OK")
				var game = peer_to_room[peer]
				game["decks"][game["players"].find(peer)] = card_ids
				send_ok(peer)
				if game["decks"][0] != null and game["decks"][1] != null:
					start_match(game)
			else:
				Logger.w("Invalid deck") # Send a denied package
		MessageType.ACTION:
			var msg_text: String = msg.slice(1).to_byte_array().get_string_from_ascii()
			if peer in peer_to_room:
				var game: Dictionary = peer_to_room[peer]
				if peer == game["players"][0]:
					Logger.i("Got action for P1: %s" % msg_text)
					game["actions"][0].push_back(msg_text)
				elif peer == game["players"][1]:
					Logger.i("Got action for P2: %s" % msg_text)
					game["actions"][1].push_back(msg_text)
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
			room.allowed_cards = int(room_info[1])
			rooms.push_back(room)
			peer_to_room[peer] = room
			send_room(room, peer)

func prepare_match(peerA, peerB) -> void:
	var msg: PackedInt32Array
	msg.append(MessageType.MATCHED)
	var game: Dictionary = {
		"players": [peerA, peerB],
		"decks": [null, null],
		"actions": [[], []]
	}
	rooms.push_back(ServerRoom.new())
	peer_to_room[peerA] = game
	peer_to_room[peerB] = game
	clients[peerA].state = ClientState.AWAIT_DECK
	clients[peerB].state = ClientState.AWAIT_DECK
	peerA.send(msg.to_byte_array())
	peerB.send(msg.to_byte_array())

func start_match(game: Dictionary):
	var game_scene = game_tscn.instantiate()
	for i in range(2):
		game_scene.player_options.push_back({
			"deck": {
				"cards": game["decks"][i]
			},
			"ai": false,
			"peer": game["players"][i]
		})
	game_scene.game_options["reveal_hands"] = false
	game_scene.game_options["online"] = "server"
	game_scene.server = self
	add_child(game_scene)
	Logger.i("Started the match")
	for peer in game["players"]:
		send_ok(peer)

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

func verify_deck(card_ids: PackedStringArray) -> int:
	var counts: Dictionary = {}
	if len(card_ids) != 40:
		return 1 # Not 40 cards
	for card_id in card_ids:
		if not CardData.has_data(card_id):
			return 2 # Has a non-existent card
		if card_id not in counts:
			counts[card_id] = 1
		else:
			counts[card_id] += 1
			if counts[card_id] > 3:
				return 3 # Has more than 3 copies of a card
	return 0

func _exit_tree() -> void:
	for peer in clients:
		peer.close()
	tcp_server.stop()

func end_board(board: GameBoard) -> void:
	board.queue_free()
	remove_child(board)
