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
		print("Client: Awaiting ", awaited_event)

func on_finish():
	pass

func process(delta):
	if awaited_event == "" and client.identities.size() > 0:
		for i in client.identities:
			var online_id: String = i.split("\t")[0]
			var card_id: String = i.split("\t")[1]
			var card: Card = game_board.get_card_from_online_id(online_id)
			card.set_id(card_id)
			print("Set identity of ", online_id, " to ", card_id)
		client.identities.clear()
	if pass_to_child("process", [delta]):
		return
	if client.events.size() > 0:
		var event: Event = fetch_event(client.events.pop_front())
		if awaited_event != "":
			print("Client: Awaited ", event.get_name())
		if parent:
			event.parent = parent
			event.parent.children.insert(event.parent.children.find(self), event)
			finish()
		else:
			queue_event(event)

func fetch_event(event_data: String):
	var args: PackedStringArray = event_data.split("\t")
	match args[0]: # Event type
		"DrawCard":
			var player: Player = game_board.players[int(args[1])]
			if len(args) > 2:
				player.deck.top().set_id(args[2])
			return EventDrawCard.new(game_board, player)
		"PhaseDraw":
			var player: Player = game_board.players[int(args[1])]
			game_board.turn_phase = Enum.Phase.DRAW
			return EventPhaseDraw.new(game_board, player, game_board.phase_effects[Enum.Phase.DRAW])
		"PhaseMove":
			var player: Player = game_board.players[int(args[1])]
			game_board.turn_phase = Enum.Phase.MOVE
			return EventPhaseMove.new(game_board, player, game_board.phase_effects[Enum.Phase.MOVE])
		"PhaseEvent":
			var player: Player = game_board.players[int(args[1])]
			game_board.turn_phase = Enum.Phase.EVENT
			return EventPhaseEventBlock.new(game_board, player, game_board.phase_effects[Enum.Phase.EVENT])
		"PhaseBlock":
			var player: Player = game_board.players[int(args[1])]
			game_board.turn_phase = Enum.Phase.BLOCK
			return EventPhaseEventBlock.new(game_board, player, game_board.phase_effects[Enum.Phase.BLOCK], true)
		"PhaseSet":
			var player: Player = game_board.players[int(args[1])]
			game_board.turn_phase = Enum.Phase.SET
			return EventPhaseSet.new(game_board, player, game_board.phase_effects[Enum.Phase.SET])
		"PhaseBattle":
			var player: Player = game_board.players[int(args[1])]
			game_board.turn_phase = Enum.Phase.BATTLE
			return EventPhaseBattle.new(game_board, player, game_board.phase_effects[Enum.Phase.BATTLE])
		"PhaseAdjust":
			var player: Player = game_board.players[int(args[1])]
			game_board.turn_phase = Enum.Phase.ADJUST
			return EventPhaseAdjust.new(game_board, player, game_board.phase_effects[Enum.Phase.ADJUST])
		"SelectDiscard":
			var player: Player = game_board.players[int(args[1])]
			return EventSelectDiscard.new(game_board, player, CardFilter.new(args[2]))
		"StartTurn":
			var player: Player = game_board.players[int(args[1])]
			game_board.turn_player_id = player.id
			return EventStartTurn.new(game_board, player)
		"Set":
			var player: Player = game_board.players[int(args[1])]
			var to_set: Card = game_board.get_card_from_online_id(args[2])
			var zone: Enum.Zone = int(args[3])
			var index: int = int(args[4])
			var targets: Array[Card] = []
			if len(args) > 5:
				for i in range(5, len(args)):
					targets.push_back(game_board.get_card_from_online_id(args[i]))
			var set_event: EventSet = EventSet.new(game_board, player, to_set)
			set_event.targets = targets
			set_event.on_zone_selected(player.field, player, zone, index)
			return set_event
		"Destroy":
			var attacker: Card = game_board.get_card_from_online_id(args[1])
			var target: Card = game_board.get_card_from_online_id(args[2])
			var source: Damage = Damage.from_online_id(args[3])
			return EventDestroy.new(game_board, attacker, target, source)
		"PayCost":
			var player: Player = game_board.players[int(args[1])]
			return EventPayCost.new(game_board, player)
		"Mulligan":
			var player: Player = game_board.players[int(args[1])]
			return EventMulligan.new(game_board, player)
		_:
			print("Unknown event: ", args[0])

func queue_event(event):
	event.parent = self
	children.push_back(event)

func on_end_phase_pressed():
	if pass_to_child("on_end_phase_pressed"):
		return
