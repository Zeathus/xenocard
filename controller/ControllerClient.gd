extends Controller

class_name ControllerClient

var response_queue: Array
var client: TCGClient

func _init(_game_board: GameBoard, _player: Player, _client: TCGClient):
	client = _client
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
