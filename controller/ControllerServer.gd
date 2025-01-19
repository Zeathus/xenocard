extends Controller

class_name ControllerServer

var response_queue: Array
var server: TCGServer
var peer: WebSocketPeer
var incoming_actions: Array

func _init(_game_board: GameBoard, _player: Player, _server: TCGServer, _peer: WebSocketPeer):
	server = _server
	peer = _peer
	incoming_actions = server.games[peer]["actions"][_player.id]
	super(_game_board, _player)

func _prepare_handling(actions: Array[Action]):
	var msg = "Waiting for"
	for i in actions:
		msg += " " + str(i)
	print(msg)
	while true:
		if incoming_actions.size() > 0:
			var incoming: PackedStringArray = incoming_actions.front().split("\t")
			var incoming_action: Action = int(incoming[0])
			if incoming_action in actions:
				break
			else:
				print("Invalid action: ", incoming_action)
		else:
			OS.delay_msec(100)
	print("Got action")

func _handle_request(action: Action, args: Array) -> bool:
	var incoming: PackedStringArray = incoming_actions.front().split("\t")
	var incoming_action: Action = int(incoming[0])
	if incoming_action != action:
		return false
	incoming_actions.pop_front()
	var inverse_in: bool = player.id == 1
	var inverse_out: bool = player.get_enemy().id == 1
	match action:
		Action.END_PHASE:
			player.get_enemy().controller.broadcast_action(incoming)
			return true
		Action.SET:
			var targets: Array[Card] = []
			if len(incoming) > 4:
				for i in range(4, len(incoming)):
					var target: Card = game_board.get_card_from_online_id(incoming[i], inverse_in)
					targets.push_back(target)
					incoming[i] = target.get_online_id(inverse_out)
			print(len(incoming), " ", len(targets))
			response_args = [game_board.get_card_from_online_id(incoming[1], inverse_in), int(incoming[2]), int(incoming[3]), targets]
			incoming[1] = response_args[0].get_online_id(inverse_out)
			player.get_enemy().controller.broadcast_action(incoming)
			return true
		Action.EVENT, Action.BLOCK:
			response_args = [game_board.get_card_from_online_id(incoming[1], inverse_in)]
			incoming[1] = response_args[0].get_online_id(inverse_out)
			player.get_enemy().controller.broadcast_action(incoming)
			return true
		Action.MOVE:
			response_args = [game_board.get_card_from_online_id(incoming[1], inverse_in), int(incoming[2]), int(incoming[3])]
			incoming[1] = response_args[0].get_online_id(inverse_out)
			player.get_enemy().controller.broadcast_action(incoming)
			return true
		Action.CONFIRM:
			response_args = [incoming[1] == "1"]
			player.get_enemy().controller.broadcast_action(incoming)
			return true
		Action.TARGET:
			response_args = [game_board.get_card_from_online_id(incoming[1], inverse_in)]
			incoming[1] = response_args[0].get_online_id(inverse_out)
			player.get_enemy().controller.broadcast_action(incoming)
			return true
		Action.SEARCH:
			var index: int = int(incoming[1])
			response_args = [index, player.deck.cards[index] if index >= 0 else null]
			incoming[1] = "0" if index >= 0 else "-1"
			player.get_enemy().controller.broadcast_action(incoming)
			return true
		Action.SEARCH_JUNK:
			var index: int = int(incoming[1])
			response_args = [index, player.junk.cards[index] if index >= 0 else null]
			player.get_enemy().controller.broadcast_action(incoming)
			return true
		Action.DISCARD:
			response_args = [game_board.get_card_from_online_id(incoming[1], inverse_in)]
			incoming[1] = response_args[0].get_online_id(inverse_out)
			player.get_enemy().controller.broadcast_action(incoming)
			return true
		Action.COUNTER:
			response_args = [game_board.get_card_from_online_id(incoming[1], inverse_in)]
			incoming[1] = response_args[0].get_online_id(inverse_out)
			player.get_enemy().controller.broadcast_action(incoming)
			return true
		Action.MULLIGAN:
			player.get_enemy().controller.broadcast_action(incoming)
			return true
	return false

func broadcast_event(event, args: Array = []):
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
	var msg: PackedByteArray = type.to_byte_array() + ('\t'.join(parts)).to_ascii_buffer()
	while len(msg) % 4 != 0:
		msg.push_back(0)
	if peer.get_ready_state() != WebSocketPeer.STATE_OPEN:
		print("Player was disconnected from server!")
	else:
		peer.send(msg)

func broadcast_action(parts: PackedStringArray):
	var type: PackedInt32Array
	type.push_back(TCGServer.MessageType.ACTION)
	var msg: PackedByteArray = type.to_byte_array() + ('\t'.join(parts)).to_ascii_buffer()
	while len(msg) % 4 != 0:
		msg.push_back(0)
	peer.send(msg)

func send_identity(online_id: String, card_id: String, awaited: bool = false):
	var type: PackedInt32Array
	type.append(TCGServer.MessageType.IDENTITY)
	var msg: PackedByteArray = type.to_byte_array() + (online_id + "\t" + card_id + "\t" + ("1" if awaited else "0")).to_ascii_buffer()
	while len(msg) % 4 != 0:
		msg.push_back(0)
	peer.send(msg)
