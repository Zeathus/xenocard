extends Node

class_name TCGClient

signal room_updated
signal countdown(value: int)

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
	NONE = 0,
	CONNECTING = 1,
	SEND_NAME = 2,
	GET_ROOMS = 3,
	IN_LOBBY = 4,
	AWAIT_HOST = 5,
	AWAIT_JOIN = 6,
	IN_ROOM = 7,
	STARTING = 8,
	QUEUING = 9,
	SENDING_DECK = 10,
	DECK_DENIED = 11,
	READY = 12,
	UNREADY = 13,
	START_GAME = 14,
	PLAYING = 15,
	STOPPED = 500
}

var websocket_url := "ws://127.0.0.1:5310" if OS.has_feature("use_local_server") else "ws%s://80.212.87.126:5310" % (
	"s" if OS.get_name() == "HTML5" or OS.get_name() == "Web" else "")

var socket := WebSocketPeer.new()
var pinged = false
var state: ClientState = ClientState.CONNECTING
var waiting_for: MessageType = MessageType.NONE
var events: Array[String] = []
var actions: Array[String] = []
var rooms: Array[ServerRoom] = []
var current_room: ServerRoom = null
var game_result: Enum.GameResult = Enum.GameResult.NONE
var ping_timer: float = 0
var last_ping: float = 0

func _ready() -> void:
	Logger.i("Connecting to " + websocket_url)
	if socket.connect_to_url(websocket_url) != OK:
		Logger.w("Unable to connect.")
		set_process(false)
	else:
		last_ping = Time.get_unix_time_from_system()

func _process(delta: float) -> void:
	socket.poll()
	
	if connected():
		ping_timer += delta
		if ping_timer >= 5:
			ping()
			ping_timer = 0
		while socket.get_available_packet_count():
			var msg: PackedInt32Array = socket.get_packet().to_int32_array()
			var type: MessageType = msg[0]
			match type:
				MessageType.PING:
					last_ping = Time.get_unix_time_from_system()
				MessageType.OK:
					if state == ClientState.SENDING_DECK:
						Logger.i("Deck OK!")
						state = ClientState.READY
					elif state == ClientState.READY:
						Logger.i("Board ready!")
						state = ClientState.START_GAME
					elif state == ClientState.SEND_NAME:
						Logger.i("Name OK!")
						waiting_for = MessageType.ROOM_LIST
						state = ClientState.GET_ROOMS
					elif state == ClientState.UNREADY:
						state = ClientState.IN_ROOM
				MessageType.DENIED:
					if state == ClientState.SEND_NAME:
						state = ClientState.STOPPED
					elif state == ClientState.AWAIT_HOST:
						Logger.w("Failed to create room")
						state = ClientState.IN_LOBBY
					elif state == ClientState.AWAIT_JOIN:
						Logger.w("Failed to join room")
						state = ClientState.IN_LOBBY
					elif state == ClientState.SENDING_DECK:
						Logger.i("Deck Denied.")
						state = ClientState.DECK_DENIED
					elif state == ClientState.UNREADY:
						Logger.i("Unexpected error on unready")
						state = ClientState.IN_ROOM
				MessageType.EVENT:
					var msg_text: String = msg.slice(1).to_byte_array().get_string_from_ascii()
					Logger.i("Got event: " + msg_text)
					if msg_text.split("\t")[0] == "EndGame":
						game_result = int(msg_text.split("\t")[1])
						events.clear()
					events.push_back(msg_text)
				MessageType.ACTION:
					var msg_text: String = msg.slice(1).to_byte_array().get_string_from_ascii()
					Logger.i("Got action: " + msg_text)
					actions.push_back(msg_text)
				MessageType.IDENTITY:
					var msg_text: String = msg.slice(1).to_byte_array().get_string_from_ascii()
					Logger.i("Got identity: " + msg_text)
					events.push_back("Identity\t" + msg_text)
				MessageType.CHAT:
					var msg_text: String = msg.slice(1).to_byte_array().get_string_from_utf8()
					Logger.i("Got a message: " + msg_text)
				MessageType.ROOM_LIST:
					var msg_text: PackedStringArray = msg.slice(1).to_byte_array().get_string_from_utf8().split("\n")
					rooms.clear()
					for i in msg_text.slice(1):
						var room: ServerRoom = ServerRoom.from_str(i)
						rooms.push_back(room)
					state = ClientState.IN_LOBBY
				MessageType.JOIN_ROOM:
					var msg_text: String = msg.slice(1).to_byte_array().get_string_from_utf8()
					if state not in [ClientState.IN_ROOM, ClientState.SENDING_DECK, ClientState.DECK_DENIED, ClientState.READY, ClientState.UNREADY, ClientState.PLAYING]:
						state = ClientState.IN_ROOM
					current_room = ServerRoom.from_str(msg_text)
					room_updated.emit()
				MessageType.COUNTDOWN:
					countdown.emit(msg[1])
				MessageType.START_GAME:
					game_result = Enum.GameResult.NONE
					state = ClientState.PLAYING

func connected() -> bool:
	return socket.get_ready_state() == WebSocketPeer.STATE_OPEN

func _exit_tree() -> void:
	socket.close()

func request_queue() -> void:
	randomize()
	var message: PackedInt32Array
	message.push_back(MessageType.QUEUE)
	socket.send(message.to_byte_array())
	waiting_for = MessageType.OK
	state = ClientState.QUEUING
	Logger.i("Sent queue request")

func send(msg: PackedByteArray):
	socket.send(msg)

func send_username():
	var type: PackedInt32Array
	type.push_back(MessageType.USERNAME)
	var username: String = Options.username
	var msg_data: PackedByteArray = type.to_byte_array() + username.to_utf8_buffer()
	while msg_data.size() % 4 != 0:
		msg_data.push_back(0)
	socket.send(msg_data)
	state = ClientState.SEND_NAME
	waiting_for = MessageType.OK
	Logger.i("Sent username: " + Options.username)

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
	Logger.i("Sent deck: " + deck_msg)

func send_unready() -> void:
	var type: PackedInt32Array
	type.push_back(MessageType.UNREADY)
	socket.send(type.to_byte_array())
	state = ClientState.UNREADY
	waiting_for = MessageType.OK

func send_chat(message: String) -> void:
	while message.length() % 4 != 0:
		message += " "
	var type: PackedInt32Array
	type.append(MessageType.CHAT)
	socket.send(type.to_byte_array() + message.to_utf8_buffer())

func get_rooms() -> void:
	var type: PackedInt32Array
	type.push_back(MessageType.ROOM_LIST)
	socket.send(type.to_byte_array())

func host_room(name: String, password: String, ruleset: int) -> void:
	var type: PackedInt32Array
	type.append(MessageType.HOST_ROOM)
	var room_info: String = "\t".join([name, password, str(ruleset)])
	var msg_data = type.to_byte_array() + room_info.to_utf8_buffer()
	while msg_data.size() % 4 != 0:
		msg_data.push_back(0)
	socket.send(msg_data)
	state = ClientState.AWAIT_HOST
	waiting_for = MessageType.JOIN_ROOM
	Logger.i("Sent room info")

func join_room(id: int, password: String) -> void:
	var type: PackedInt32Array
	type.append(MessageType.JOIN_ROOM)
	type.append(id)
	var msg_data = type.to_byte_array() + password.to_utf8_buffer()
	while msg_data.size() % 4 != 0:
		msg_data.push_back(0)
	socket.send(msg_data)
	state = ClientState.AWAIT_JOIN
	waiting_for = MessageType.JOIN_ROOM

func leave_room() -> void:
	var type: PackedInt32Array
	type.append(MessageType.JOIN_ROOM)
	type.append(-1)
	socket.send(type.to_byte_array())
	state = ClientState.IN_LOBBY

func ping() -> void:
	var type: PackedInt32Array
	type.push_back(MessageType.PING)
	socket.send(type.to_byte_array())
