extends Controller

class_name ControllerClient

var response_queue: Array
var client: TCGClient
var incoming_actions: Array
var identities: Array[String]

func _init(_game_board: GameBoard, _player: Player, _client: TCGClient):
	client = _client
	incoming_actions = client.actions
	identities = client.identities
	super(_game_board, _player)

func _prepare_handling(actions: Array[Action]):
	while true:
		if incoming_actions.size() > 0 and len(identities) == 0:
			var incoming: PackedStringArray = incoming_actions.front().split("\t")
			var incoming_action: Action = int(incoming[0])
			if incoming_action in actions:
				break
			else:
				print("Invalid action: ", incoming_action)
		else:
			OS.delay_msec(100)

func _handle_request(action: Action, args: Array) -> bool:
	var incoming: PackedStringArray = incoming_actions.front().split("\t")
	var incoming_action: Action = int(incoming[0])
	if incoming_action != action:
		return false
	incoming_actions.pop_front()
	match action:
		Action.END_PHASE:
			return true
		Action.SET:
			var targets: Array[Card] = []
			if len(incoming) > 4:
				for i in range(4, len(incoming)):
					var target: Card = game_board.get_card_from_online_id(incoming[i])
					targets.push_back(target)
			response_args = [game_board.get_card_from_online_id(incoming[1]), int(incoming[2]), int(incoming[3]), targets]
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
			response_args = [game_board.get_card_from_online_id(incoming[1])]
			return true
		Action.COUNTER:
			return true
		Action.MULLIGAN:
			return true
	return false

func send_action(action: Controller.Action, args: Array[String] = []):
	var parts: Array[String] = [str(action)]
	parts += args
	var type: PackedInt32Array
	type.push_back(TCGServer.MessageType.ACTION)
	var msg: PackedByteArray = type.to_byte_array() + ('\t'.join(parts)).to_ascii_buffer()
	while len(msg) % 4 != 0:
		msg.push_back(0)
	client.send(msg)
