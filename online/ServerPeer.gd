class_name ServerPeer

static var name_regex: RegEx

var peer: WebSocketPeer
var state: TCGServer.ClientState
var name: String
var ping_timer: float
var last_ping: float

func _init(_peer: WebSocketPeer) -> void:
	peer = _peer
	state = TCGServer.ClientState.AWAIT_NAME
	name = ""
	ping_timer = 0
	last_ping = Time.get_unix_time_from_system()

func is_in_room() -> bool:
	return state in [
		TCGServer.ClientState.IN_ROOM,
		TCGServer.ClientState.READY,
		TCGServer.ClientState.PLAYING
	]

static func _static_init() -> void:
	name_regex = RegEx.new()
	name_regex.compile("[^A-Z^a-z^0-9^_]")

static func verify_name(_name: String) -> bool:
	if len(_name) < 3 or len(_name) > 15:
		return false
	if name_regex.search(_name):
		return false
	return true
