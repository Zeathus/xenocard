extends Node

class_name TCGServer

enum MessageType {
	NONE = 0,
	QUEUE = 1,
	MATCHED = 2,
	DECK = 3,
	CHAT = 10,
	OK = 200,
	DENIED = 400,
	ERROR = 500
}

enum ClientState {
	IDLE = 1,
	QUEUING = 2,
	AWAIT_DECK = 3
}

const PORT = 9080

var tcp_server = TCPServer.new()
var game_tscn = preload("res://scenes/game_board.tscn")
var games: Dictionary = {}
var clients: Dictionary = {}
var queue: Array

func log_message(message: String) -> void:
	var time := "[%s]" % Time.get_time_string_from_system()
	print(time, " ", message)

func _ready() -> void:
	if tcp_server.listen(PORT) != OK:
		log_message("Unabled to start server. Failed to listen to port.")
		set_process(false)

func _process(delta: float) -> void:
	while tcp_server.is_connection_available():
		var conn: StreamPeerTCP = tcp_server.take_connection()
		assert(conn != null)
		var socket: WebSocketPeer = WebSocketPeer.new()
		socket.accept_stream(conn)
		clients[socket] = {
			"state": ClientState.IDLE
		}
		print("Got new connection from ", socket.get_connected_host())
	
	for socket in clients:
		socket.poll()
		if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
			while socket.get_available_packet_count():
				handle_packet(socket)
	
	if len(queue) >= 2:
		var do_break: bool = false
		for i in range(queue.size() - 1):
			for j in range(i + 1, queue.size()):
				if clients[queue[i]]["password"] == clients[queue[j]]["password"]:
					print("We found a match!")
					prepare_match(queue[i], queue[j])
					queue.erase(queue[j])
					queue.erase(queue[i])
					return

func handle_packet(socket: WebSocketPeer):
	var msg_data: PackedByteArray = socket.get_packet()
	var msg: PackedInt32Array = msg_data.to_int32_array()
	var type: MessageType = msg[0]
	match type:
		MessageType.QUEUE:
			if clients[socket]["state"] != ClientState.IDLE:
				print("Deny queue request")
				pass # Deny the connection
			else:
				print("Client ", socket.get_connected_host(), " queued")
				clients[socket]["state"] = ClientState.QUEUING
				clients[socket]["password"] = ""
				queue.push_back(socket)
				send_ok(socket)
		MessageType.CHAT:
			var msg_text: String = msg.slice(1).to_byte_array().get_string_from_utf8()
			print("Sending chat: ", msg_text)
			send_chat(socket, msg_text)
		MessageType.DECK:
			if clients[socket]["state"] != ClientState.AWAIT_DECK or socket not in games:
				return
			var card_ids: PackedStringArray = msg.slice(1).to_byte_array().get_string_from_ascii().split(",")
			if verify_deck(card_ids) == 0:
				print("Server: Deck OK")
				var game = games[socket]
				game["decks"][game["players"].find(socket)] = card_ids
				send_ok(socket)
				if game["decks"][0] != null and game["decks"][1] != null:
					start_match(game)
			else:
				print("Invalid deck") # Send a denied package

func prepare_match(socketA, socketB) -> void:
	var msg: PackedInt32Array
	msg.append(MessageType.MATCHED)
	var game: Dictionary = {
		"players": [socketA, socketB],
		"decks": [null, null]
	}
	games[socketA] = game
	games[socketB] = game
	clients[socketA]["state"] = ClientState.AWAIT_DECK
	clients[socketB]["state"] = ClientState.AWAIT_DECK
	socketA.send(msg.to_byte_array())
	socketB.send(msg.to_byte_array())

func start_match(game: Dictionary):
	var game_scene = game_tscn.instantiate()
	for i in range(2):
		game_scene.player_options.push_back({
			"deck": {
				"cards": game["decks"][i]
			},
			"ai": false
		})
	game_scene.game_options["reveal_hands"] = false
	add_child(game_scene)
	print("Started the match")
	for socket in game["players"]:
		send_ok(socket)

func send_chat(socket: WebSocketPeer, message: String) -> void:
	if socket in games:
		var type: PackedInt32Array
		type.append(MessageType.CHAT)
		for player: WebSocketPeer in games[socket]["players"]:
			if player != socket:
				player.send(type.to_byte_array() + message.to_utf8_buffer())

func send_ok(socket: WebSocketPeer) -> void:
	var msg: PackedInt32Array
	msg.append(MessageType.OK)
	socket.send(msg.to_byte_array())

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
	for socket in clients:
		socket.close()
	tcp_server.stop()
