extends Node

class_name TCGServer

enum MessageType {
	NONE = 0,
	QUEUE = 1,
	MATCHED = 2,
	CHAT = 10,
	OK = 200,
	DENIED = 400,
	ERROR = 500
}

enum ClientState {
	IDLE = 1,
	QUEUING = 2
}

const PORT = 9080

var tcp_server = TCPServer.new()
var game_scene = preload("res://scenes/game_board.tscn")
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
					start_match(queue[i], queue[j])
					queue.erase(queue[j])
					queue.erase(queue[i])
					return
	#if msg == "Ping":
		#print("Ping")
	#elif msg == "Pong":
		#print("Pong: Start game")
		#var game = game_scene.instantiate()
		#add_player_options(game)
		#add_player_options(game)
		#game.game_options["reveal_hands"] = false
		#add_child(game)

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

func start_match(socketA, socketB) -> void:
	var msg: PackedInt32Array
	msg.append(MessageType.MATCHED)
	var game: Dictionary = {
		"players": [socketA, socketB]
	}
	games[socketA] = game
	games[socketB] = game
	socketA.send(msg.to_byte_array())
	socketB.send(msg.to_byte_array())

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

func _exit_tree() -> void:
	for socket in clients:
		socket.close()
	tcp_server.stop()

var decks: Array[String] = DeckData.list_presets()
var deck_idx: int = 0

func add_player_options(game: GameBoard):
	var options = {
		"deck": {
			"name": decks[deck_idx],
			"preset": true
		},
		"ai": true
	}
	game.player_options.push_back(options)
	deck_idx = (deck_idx + 1) % decks.size()
