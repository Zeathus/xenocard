extends Node

class_name TCGClient

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
	STARTING = 1,
	QUEUING = 2
}

var websocket_url := "ws://localhost:9080"

var socket := WebSocketPeer.new()
var pinged = false
var state: ClientState = ClientState.STARTING
var waiting_for: MessageType = MessageType.NONE

func _ready() -> void:
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
						waiting_for = MessageType.NONE
				MessageType.MATCHED:
					if state == ClientState.QUEUING:
						print("We were matched!")
						var id: String = str(randi())
						print("Sending 'Hello' with ID " + id)
						send_chat("Hello! " + id)
				MessageType.CHAT:
					var msg_text: String = msg.slice(1).to_byte_array().get_string_from_utf8()
					print("Got a message: ", msg_text)
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
	waiting_for = MessageType.QUEUE
	state = ClientState.QUEUING
	print("Sent queue request")

func send_chat(message: String) -> void:
	while message.length() % 4 != 0:
		message += " "
	var type: PackedInt32Array
	type.append(MessageType.CHAT)
	socket.send(type.to_byte_array() + message.to_utf8_buffer())
