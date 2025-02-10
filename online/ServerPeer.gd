class_name ServerPeer

static var name_regex: RegEx

var peer: WebSocketPeer
var state: TCGServer.ClientState
var name: String

func _init(_peer: WebSocketPeer) -> void:
	peer = _peer
	state = TCGServer.ClientState.AWAIT_NAME
	name = ""

static func _static_init() -> void:
	name_regex = RegEx.new()
	name_regex.compile("[^A-Z^a-z^0-9^_]")

static func verify_name(_name: String) -> bool:
	if len(_name) < 3 or len(_name) > 15:
		return false
	if name_regex.search(_name):
		return false
	return true
