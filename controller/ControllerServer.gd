extends Controller

class_name ControllerServer

var response_queue: Array
var client: TCGServer
var peer: WebSocketPeer

func _init(_game_board: GameBoard, _player: Player, _client: TCGServer, _peer: WebSocketPeer):
	client = _client
	peer = _peer
	super(_game_board, _player)

func _prepare_handling(actions: Array[Action]):
	pass

func _handle_request(action: Action, args: Array) -> bool:
	return false
	match action:
		Action.END_PHASE:
			return true
		Action.SET:
			return true
		Action.EVENT, Action.BLOCK:
			return true
		Action.MOVE:
			return true
		Action.CONFIRM:
			return true
		Action.TARGET:
			return true
		Action.SEARCH:
			return true
		Action.SEARCH_JUNK:
			return true
		Action.DISCARD:
			return true
		Action.COUNTER:
			return true
		Action.MULLIGAN:
			return true
	return false

func broadcast_event(event, args):
	var parts: Array[String] = [event]
	for arg in args:
		if arg is Player:
			if player.id == 0:
				parts.push_back(str(arg.id))
			else:
				parts.push_back(str((arg.id + 1) % 2))
		else:
			parts.push_back(str(arg))
	var type: PackedInt32Array
	type.push_back(TCGServer.MessageType.EVENT)
	var msg: PackedByteArray = type.to_byte_array() + (','.join(parts)).to_ascii_buffer()
	while len(msg) % 4 != 0:
		msg.push_back(0)
	peer.send(msg)
