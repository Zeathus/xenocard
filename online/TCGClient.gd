extends Node

class_name TCGClient

var websocket_url := "ws://localhost:9080"

var socket := WebSocketPeer.new()

func _ready() -> void:
	if socket.connect_to_url(websocket_url) != OK:
		print("Unable to connect.")
		set_process(false)

func _process(_delta: float) -> void:
	socket.poll()
	
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			print(socket.get_packet().get_string_from_ascii())
	
	ping()

func _exit_tree() -> void:
	socket.close()

func ping() -> void:
	socket.send_text("Ping")
