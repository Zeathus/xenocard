extends Event

class_name EventOnlineClient

var client: TCGClient
var awaited_event: String

func _init(_game_board: GameBoard, _client: TCGClient, _awaited_event: String = ""):
	broadcasted = false
	client = _client
	awaited_event = _awaited_event
	super(_game_board)

func get_name() -> String:
	return "OnlineClient"

func on_start():
	if awaited_event != "":
		print("Awaiting ", awaited_event)

func on_finish():
	pass

func process(delta):
	if pass_to_child("process", [delta]):
		return
	if client.events.size() > 0:
		var event: Event = fetch_event(client.events.pop_front())
		if parent:
			event.parent = parent
			event.parent.children.insert(event.parent.children.find(self), event)
			finish()
		else:
			queue_event(event)

func fetch_event(event_data: String):
	var args: PackedStringArray = event_data.split(",")
	match args[0]: # Event type
		"DrawCard":
			var player: Player = game_board.players[int(args[1])]
			if len(args) > 2:
				player.deck.top().set_id(args[2])
			return EventDrawCard.new(game_board, player)
		"StartTurn":
			var player: Player = game_board.players[int(args[1])]
			return EventStartTurn.new(game_board, player)
		"Mulligan":
			var player: Player = game_board.players[int(args[1])]
			return EventMulligan.new(game_board, player)
		"PhaseDraw":
			var player: Player = game_board.players[int(args[1])]
			return EventPhaseDraw.new(game_board, player, game_board.phase_effects[Enum.Phase.DRAW])
		"PhaseMove":
			var player: Player = game_board.players[int(args[1])]
			return EventPhaseMove.new(game_board, player, game_board.phase_effects[Enum.Phase.MOVE])
		"PhaseEventBlock":
			var player: Player = game_board.players[int(args[1])]
			return EventPhaseEventBlock.new(game_board, player, game_board.phase_effects[Enum.Phase.BLOCK])
		"PhaseSet":
			var player: Player = game_board.players[int(args[1])]
			return EventPhaseSet.new(game_board, player, game_board.phase_effects[Enum.Phase.SET])
		"PhaseBattle":
			var player: Player = game_board.players[int(args[1])]
			return EventPhaseBattle.new(game_board, player, game_board.phase_effects[Enum.Phase.BATTLE])
		"PhaseAdjust":
			var player: Player = game_board.players[int(args[1])]
			return EventPhaseAdjust.new(game_board, player, game_board.phase_effects[Enum.Phase.ADJUST])
		_:
			print("Unknown event: ", args[0])

func queue_event(event):
	event.parent = self
	children.push_back(event)

func on_end_phase_pressed():
	if pass_to_child("on_end_phase_pressed"):
		return
