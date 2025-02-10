extends Event

class_name EventOnlineClient

var client: TCGClient
var awaited_event: Event

func _init(_game_board: GameBoard, _client: TCGClient, _awaited_event: Event = null):
	broadcasted = false
	client = _client
	awaited_event = _awaited_event
	super(_game_board)

func get_name() -> String:
	return "OnlineClient"

func on_start():
	if awaited_event != null:
		Logger.i("Awaiting %s" % awaited_event.get_name())

func on_finish():
	pass

func process(delta):
	if pass_to_child("process", [delta]):
		return
	if client.events.size() > 0:
		var event: Event = fetch_event(client.events.pop_front())
		if awaited_event != null:
			Logger.i("Awaited %s" % event.get_name())
			if awaited_event.get_name() != event.get_name() and event is not EventIdentity:
				Logger.e("Got unexpected event %s, expected %s" % [event.get_name(), awaited_event.get_name()])
				return
		if parent and not (event is EventIdentity and not event.awaited):
			event.parent = parent
			event.parent.children.insert(event.parent.children.find(self), event)
			finish()
		else:
			queue_event(event)

func fetch_event(event_data: String):
	var args: PackedStringArray = event_data.split("\t")
	match args[0]: # Event type
		"Identity":
			var online_id: String = args[1]
			var card_id: String = args[2]
			var awaited: bool = (args[3] == "1")
			return EventIdentity.new(game_board, online_id, card_id, awaited)
		"StartTurn":
			var player: Player = game_board.players[int(args[1])]
			game_board.turn_player_id = player.id
			return EventStartTurn.new(game_board, player)
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
		"DrawCard":
			var player: Player = game_board.players[int(args[1])]
			if len(args) > 2 and player.deck.size() > 0:
				player.deck.top().set_id(args[2])
			return EventDrawCard.new(game_board, player)
		"DrawCardFromLost":
			var player: Player = game_board.players[int(args[1])]
			if len(args) > 2 and player.lost.size() > 0:
				player.lost.top().set_id(args[2])
			return EventDrawCardFromLost.new(game_board, player)
		"Move":
			var player: Player = game_board.players[int(args[1])]
			var to_move: Card = game_board.get_card_from_online_id(args[2])
			var zone: Enum.Zone = int(args[3])
			var index: int = int(args[4])
			var move_event: EventMove = EventMove.new(game_board, player, to_move)
			move_event.on_zone_selected(player.field, player, zone, index)
			return move_event
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
			for t in targets:
				t.select()
			set_event.targets = targets
			set_event.on_zone_selected(player.field, player, zone, index)
			return set_event
		"Event":
			var activated: Card = game_board.get_card_from_online_id(args[1])
			var block: bool = args[2] == "1"
			return EventEvent.new(game_board, activated, block)
		"CounterPrompt":
			var countered: Card = game_board.get_card_from_online_id(args[1])
			var chain: Array[Card] = []
			if len(args) > 2:
				for i in range(2, len(args)):
					chain.push_back(game_board.get_card_from_online_id(args[i]))
			return EventCounterPrompt.new(game_board, countered.owner.get_enemy(), countered, chain)
		"Counter":
			var countered: Card = game_board.get_card_from_online_id(args[1])
			var countering: Card = game_board.get_card_from_online_id(args[2])
			var chain: Array[Card] = []
			if len(args) > 3:
				for i in range(3, len(args)):
					chain.push_back(game_board.get_card_from_online_id(args[i]))
			return EventCounter.new(game_board, countered.owner.get_enemy(), countered, countering, chain)
		"Attack":
			var attacker: Card = game_board.get_card_from_online_id(args[1])
			return EventAttack.new(game_board, attacker)
		"SpecialAttack":
			var attacker: Card = game_board.get_card_from_online_id(args[1])
			var damage: int = int(args[2])
			var filter: CardFilter = CardFilter.new(args[3])
			return EventSpecialAttack.new(game_board, attacker, damage, filter)
		"Damage":
			var attacker: Card = game_board.get_card_from_online_id(args[1])
			var target = attacker.owner.get_enemy() if args[2] == "player" else game_board.get_card_from_online_id(args[2])
			var damage: int = int(args[3])
			var source: Damage = Damage.from_online_id(args[4])
			return EventDamage.new(game_board, attacker, target, damage, source)
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
			return EventMulligan.new(game_board, player, int(args[2]))
		"Recover":
			var player: Player = game_board.players[int(args[1])]
			var amount: int = int(args[2])
			return EventRecover.new(game_board, player, amount)
		"Search":
			var player: Player = game_board.players[int(args[1])]
			var filter: CardFilter = CardFilter.new(args[2])
			var deck_size: int = int(args[3])
			for i in range(deck_size):
				player.deck.cards[i].set_id(args[4 + i])
			awaited_event.filter = filter
			return awaited_event
		"SearchJunk":
			var player: Player = game_board.players[int(args[1])]
			var filter: CardFilter = CardFilter.new(args[2])
			awaited_event.filter = filter
			return awaited_event
		"Excavate":
			var player: Player = game_board.players[int(args[1])]
			var filter: CardFilter = CardFilter.new(args[2])
			var deck_size: int = int(args[3])
			for i in range(deck_size):
				player.deck.cards[i].set_id(args[4 + i])
			awaited_event.filter = filter
			return awaited_event
		"FieldToHand":
			var card: Card = game_board.get_card_from_online_id(args[1])
			return EventFieldToHand.new(game_board, card)
		"AutoMove":
			var to_move: Card = game_board.get_card_from_online_id(args[1])
			var zone: Enum.Zone = int(args[2])
			var index: int = int(args[3])
			return EventAutoMove.new(game_board, to_move.owner, to_move, zone, index)
		"AutoSet":
			var to_set: Card = game_board.get_card_from_online_id(args[1])
			var zone: Enum.Zone = int(args[2])
			var index: int = int(args[3])
			return EventAutoSet.new(game_board, to_set.owner, to_set, zone, index)
		"Confirm":
			if args.size() > 1:
				game_board.dummy_card.set_id(args[1])
				awaited_event.card_preview = game_board.dummy_card
			return awaited_event
		"EndGame":
			var result: Enum.GameResult = int(args[1])
			return EventEndGame.new(game_board, result)
		_:
			Logger.w("Unknown event: %s" % args[0])

func queue_event(event):
	event.parent = self
	children.push_back(event)

func on_end_phase_pressed():
	if pass_to_child("on_end_phase_pressed"):
		return
