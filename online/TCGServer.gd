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

const PORT = 5310

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
		var peer: WebSocketPeer = WebSocketPeer.new()
		peer.accept_stream(conn)
		clients[peer] = {
			"state": ClientState.IDLE
		}
		Logger.i("Got new connection from %s" % peer.get_connected_host())
	
	for peer in clients:
		peer.poll()
		if peer.get_ready_state() == WebSocketPeer.STATE_OPEN:
			while peer.get_available_packet_count():
				handle_packet(peer)
	
	if len(queue) >= 2:
		for i in range(queue.size() - 1):
			for j in range(i + 1, queue.size()):
				if clients[queue[i]]["password"] == clients[queue[j]]["password"]:
					Logger.i("We found a match!")
					prepare_match(queue[i], queue[j])
					queue.erase(queue[j])
					queue.erase(queue[i])
					return

func handle_packet(peer: WebSocketPeer):
	var msg_data: PackedByteArray = peer.get_packet()
	var msg: PackedInt32Array = msg_data.to_int32_array()
	var type: MessageType = msg[0]
	match type:
		MessageType.QUEUE:
			if clients[peer]["state"] != ClientState.IDLE:
				Logger.w("Deny queue request")
				pass # Deny the connection
			else:
				Logger.i("Client " + peer.get_connected_host() + " queued")
				clients[peer]["state"] = ClientState.QUEUING
				clients[peer]["password"] = ""
				queue.push_back(peer)
				send_ok(peer)
		MessageType.CHAT:
			var msg_text: String = msg.slice(1).to_byte_array().get_string_from_utf8()
			print("Sending chat: ", msg_text)
			send_chat(peer, msg_text)
		MessageType.DECK:
			if clients[peer]["state"] != ClientState.AWAIT_DECK or peer not in games:
				return
			var card_ids: PackedStringArray = msg.slice(1).to_byte_array().get_string_from_ascii().split(",")
			if verify_deck(card_ids) == 0:
				Logger.i("Deck OK")
				var game = games[peer]
				game["decks"][game["players"].find(peer)] = card_ids
				send_ok(peer)
				if game["decks"][0] != null and game["decks"][1] != null:
					start_match(game)
			else:
				Logger.w("Invalid deck") # Send a denied package
		MessageType.ACTION:
			var msg_text: String = msg.slice(1).to_byte_array().get_string_from_ascii()
			if peer in games:
				var game: Dictionary = games[peer]
				if peer == game["players"][0]:
					Logger.i("Got action for P1: %s" % msg_text)
					games[peer]["actions"][0].push_back(msg_text)
				elif peer == game["players"][1]:
					Logger.i("Got action for P2: %s" % msg_text)
					games[peer]["actions"][1].push_back(msg_text)

func prepare_match(peerA, peerB) -> void:
	var msg: PackedInt32Array
	msg.append(MessageType.MATCHED)
	var game: Dictionary = {
		"players": [peerA, peerB],
		"decks": [null, null],
		"actions": [[], []]
	}
	games[peerA] = game
	games[peerB] = game
	clients[peerA]["state"] = ClientState.AWAIT_DECK
	clients[peerB]["state"] = ClientState.AWAIT_DECK
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
	if peer in games:
		var type: PackedInt32Array
		type.append(MessageType.CHAT)
		for player: WebSocketPeer in games[peer]["players"]:
			if player != peer:
				player.send(type.to_byte_array() + message.to_utf8_buffer())

func send_ok(peer: WebSocketPeer) -> void:
	var msg: PackedInt32Array
	msg.append(MessageType.OK)
	peer.send(msg.to_byte_array())

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
