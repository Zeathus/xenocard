extends Node

class_name TCGClient

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
	STARTING = 1,
	QUEUING = 2,
	AWAIT_DECK = 3,
	SENDING_DECK = 4,
	AWAIT_BOARD = 5,
	START_GAME = 6,
	PLAYING = 7
}

var websocket_url := "ws://127.0.0.1:5310" if OS.has_feature("use_local_server") else "ws://80.212.87.126:5310"

var socket := WebSocketPeer.new()
var pinged = false
var state: ClientState = ClientState.STARTING
var waiting_for: MessageType = MessageType.NONE
var events: Array[String] = []
var actions: Array[String] = []

func _ready() -> void:
	print("Connecting to ", websocket_url)
	if socket.connect_to_url(websocket_url) != OK:
		print("Unable to connect.")
		set_process(false)

func _process(_delta: float) -> void:
	socket.poll()
	
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var msg: PackedInt32Array = socket.get_packet().to_int32_array()
			var type: MessageType = msg[0]
			match type:
				MessageType.OK:
					if state == ClientState.QUEUING:
						print("We were queued!")
						waiting_for = MessageType.MATCHED
					elif state == ClientState.SENDING_DECK:
						print("Client: Deck OK!")
						state = ClientState.AWAIT_BOARD
					elif state == ClientState.AWAIT_BOARD:
						print("Board ready!")
						state = ClientState.START_GAME
				MessageType.MATCHED:
					if state == ClientState.QUEUING:
						print("We were matched!")
						state = ClientState.AWAIT_DECK
				MessageType.EVENT:
					var msg_text: String = msg.slice(1).to_byte_array().get_string_from_ascii()
					print("Client: Got event: ", msg_text)
					events.push_back(msg_text)
				MessageType.ACTION:
					var msg_text: String = msg.slice(1).to_byte_array().get_string_from_ascii()
					print("Client: Got action: ", msg_text)
					actions.push_back(msg_text)
				MessageType.IDENTITY:
					var msg_text: String = msg.slice(1).to_byte_array().get_string_from_ascii()
					print("Client: Got identity: ", msg_text)
					events.push_back("Identity\t" + msg_text)
				MessageType.CHAT:
					var msg_text: String = msg.slice(1).to_byte_array().get_string_from_utf8()
					print("Client: Got a message: ", msg_text)
		if waiting_for == MessageType.NONE:
			match state:
				ClientState.STARTING:
					request_queue()

func _exit_tree() -> void:
	socket.close()

func request_queue() -> void:
	randomize()
	var message: PackedInt32Array
	message.push_back(MessageType.QUEUE)
	socket.send(message.to_byte_array())
	waiting_for = MessageType.OK
	state = ClientState.QUEUING
	print("Sent queue request")

func send(msg: PackedByteArray):
	socket.send(msg)

func send_deck(deck: Deck) -> void:
	var type: PackedInt32Array
	type.push_back(MessageType.DECK)
	var deck_msg: String = ""
	for card in deck.cards:
		if len(deck_msg) > 0:
			deck_msg += ","
		deck_msg += "%s/%s" % [card.get_set_name(), card.get_id()]
	var msg_data: PackedByteArray = type.to_byte_array() + deck_msg.to_ascii_buffer()
	while msg_data.size() % 4 != 0:
		msg_data.push_back(0)
	socket.send(msg_data)
	state = ClientState.SENDING_DECK
	waiting_for = MessageType.OK
	print("Sent: ", deck_msg)

func send_chat(message: String) -> void:
	while message.length() % 4 != 0:
		message += " "
	var type: PackedInt32Array
	type.append(MessageType.CHAT)
	socket.send(type.to_byte_array() + message.to_utf8_buffer())
