extends Node2D

class_name GameBoard

var quick_details_enabled: bool = true
var quick_detail_card: Card = null
var quick_detail_card_timer: float = 0

var players: Array[Player]
var turn_player_id: int = 0
var turn_phase: Enum.Phase = Enum.Phase.DRAW
var card_zones: Array[Node2D]
var event_queue: Array[Event]
var free_menu = null
var phase_effects: Dictionary
var player_options: Array[Dictionary] = []
var game_options: Dictionary = {}
var countering_player: Player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in Enum.Phase:
		phase_effects[Enum.Phase[i]] = []
	card_zones = []
	for node in find_children("Zone?", "Node2D"):
		card_zones.push_back(node)
	for i in range(2):
		var options: Dictionary = player_options[i]
		var player: Player = Player.new(
			i,
			Deck.load(options["deck"]["name"], options["deck"]["preset"]),
			[$FieldPlayer, $FieldEnemy][i],
			[$HandPlayer, $HandEnemy][i],
			self
		)
		player.show_hand = (not options["ai"]) or game_options["reveal_hands"]
		if options["ai"]:
			player.controller = ControllerAI.new(self, player)
			player.controller.start()
		players.push_back(player)
	for p in players:
		for i in range(5):
			queue_event(EventDrawCard.new(self, p, 2))
	turn_player_id = 0
	begin_turn()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var event_str: String = "Events: ["
	for e in event_queue:
		if e != event_queue.front():
			event_str += " "
		event_str += event_to_str(e)
	event_str += "]"
	$TestLabel.text = event_str
	
	if quick_detail_card:
		if quick_detail_card.is_hovered():
			quick_detail_card_timer = 0.25
		else:
			quick_detail_card_timer -= delta
			if quick_detail_card_timer <= 0:
				$QuickDetails/Left.visible = false
				$QuickDetails/Right.visible = false
				quick_detail_card = null
	
	if $CardDetails.visible:
		if Input.is_action_just_pressed("left_click"):
			$CardDetails.visible = false
	elif free_menu:
		if free_menu.is_done():
			$Menus.remove_child(free_menu)
			free_menu.finish()
			free_menu = null
	if event_processing():
		var event = get_event()
		event.process(delta)
		if event.is_done():
			event_queue.pop_front()
		return

func add_menu(menu, _z_index=0):
	menu.z_index = _z_index
	$Menus.add_child(menu)

func remove_menu(menu):
	$Menus.remove_child(menu)
	menu.queue_free()

func event_to_str(event: Event) -> String:
	var ret: String = event.get_name()
	if event.has_children():
		ret += ">["
		for e in event.children:
			if e != event.children.front():
				ret += " "
			ret += event_to_str(e)
		ret += "]"
	return ret

func event_processing() -> bool:
	return len(event_queue) > 0

func get_event() -> Event:
	return event_queue.front()

func queue_event(event: Event):
	event_queue.push_back(event)

func queue_next_event(event: Event):
	event_queue.insert(1, event)

func is_free() -> bool:
	return free_menu == null and not $CardDetails.visible

func skips_phase(phase: Enum.Phase, player: Player):
	for card in get_all_field_cards():
		for e in card.get_effects(Enum.Trigger.PASSIVE):
			if e.skips_phase(phase, player):
				return true
	return false

func begin_phase(phase: Enum.Phase):
	turn_phase = phase
	var player: Player = get_turn_player()
	match turn_phase:
		Enum.Phase.DRAW:
			$Phases/Phase/Label.text = "%dP Draw Phase" % (turn_player_id + 1)
			queue_event(EventPhaseDraw.new(self, player, phase_effects[Enum.Phase.DRAW]))
		Enum.Phase.MOVE:
			$Phases/Phase/Label.text = "%dP Move Phase" % (turn_player_id + 1)
			queue_event(EventPhaseMove.new(self, player, phase_effects[Enum.Phase.MOVE]))
		Enum.Phase.EVENT:
			$Phases/Phase/Label.text = "%dP Event Phase" % (turn_player_id + 1)
			queue_event(EventPhaseEventBlock.new(self, player, phase_effects[Enum.Phase.EVENT], false))
		Enum.Phase.SET:
			$Phases/Phase/Label.text = "%dP Set Phase" % (turn_player_id + 1)
			queue_event(EventPhaseSet.new(self, player, phase_effects[Enum.Phase.SET]))
		Enum.Phase.BLOCK:
			$Phases/Phase/Label.text = "%dP Block Phase" % ((turn_player_id + 1) % 2 + 1)
			queue_event(EventPhaseEventBlock.new(self, player, phase_effects[Enum.Phase.BLOCK], true))
		Enum.Phase.BATTLE:
			$Phases/Phase/Label.text = "%dP Battle Phase" % (turn_player_id + 1)
			queue_event(EventPhaseBattle.new(self, player, phase_effects[Enum.Phase.BATTLE]))
		Enum.Phase.ADJUST:
			$Phases/Phase/Label.text = "%dP Adjust Phase" % (turn_player_id + 1)
			queue_event(EventPhaseAdjust.new(self, player, phase_effects[Enum.Phase.ADJUST]))

func end_phase():
	match turn_phase:
		Enum.Phase.DRAW:
			begin_phase(Enum.Phase.MOVE)
		Enum.Phase.MOVE:
			begin_phase(Enum.Phase.EVENT)
		Enum.Phase.EVENT:
			begin_phase(Enum.Phase.SET)
		Enum.Phase.SET:
			begin_phase(Enum.Phase.BLOCK)
		Enum.Phase.BLOCK:
			begin_phase(Enum.Phase.BATTLE)
		Enum.Phase.BATTLE:
			begin_phase(Enum.Phase.ADJUST)
		Enum.Phase.ADJUST:
			next_player()
			begin_turn()
	refresh()

func begin_turn():
	var turn_player: Player = get_turn_player()
	turn_player.used_one_battle_card_per_turn = false
	turn_player.used_one_situation_card_per_turn = false
	begin_phase(Enum.Phase.DRAW)

func refresh():
	for player in [get_turn_player(), get_turn_enemy()]:
		player.field.refresh()
		player.set_reveal_hand(false)
		for card in get_all_field_cards():
			for e in card.get_effects(Enum.Trigger.PASSIVE):
				var reveal_hand = e.reveal_hand(player)
				if reveal_hand:
					player.set_reveal_hand(reveal_hand)
			var duration = 0
			for e in card.effects:
				if e.duration > 0:
					duration = e.duration
					break
			card.instance.set_duration(duration)

func next_player():
	turn_player_id = (turn_player_id + 1) % 2

func prepare_card(card: Card) -> Card:
	card.reset()
	card.instance.show_details.connect(_on_card_show_details)
	card.instance.on_hover.connect(_on_card_hovered)
	return card

func get_turn_player() -> Player:
	var player_id: int = turn_player_id
	if turn_phase == Enum.Phase.BLOCK:
		player_id = (player_id + 1) % 2
	return players[player_id]

func get_turn_enemy() -> Player:
	return get_turn_player().get_enemy()

func hide_valid_zones():
	get_turn_player().field.hide_valid_zones()
	get_turn_enemy().field.hide_valid_zones()

func get_all_field_cards() -> Array[Card]:
	var result: Array[Card] = []
	result += get_turn_player().field.get_all_cards()
	result += get_turn_enemy().field.get_all_cards()
	return result

func get_all_battlefield_cards() -> Array[Card]:
	var result: Array[Card] = []
	result += get_turn_player().field.get_battlefield_cards()
	result += get_turn_enemy().field.get_battlefield_cards()
	return result

func add_phase_effect(phase: Enum.Phase, effect: Effect):
	phase_effects[phase].push_back(effect)

func play_se(name: String):
	var sound = load("res://audio/se/" + name + ".wav")
	for player in [$AudioStream1, $AudioStream2, $AudioStream3]:
		if not player.is_playing():
			player.stream = sound
			player.play()
			break

func show_details(card):
	$CardDetails.visible = true
	$CardDetails/CardNode.turn_up()
	$CardDetails/CardNode.show_card(card.data)

func _on_card_show_details(card):
	show_details(card)

func _on_card_hovered(card):
	$QuickDetails/Left.visible = false
	$QuickDetails/Right.visible = false
	var display = $QuickDetails/Left
	var display_card = $QuickDetails/Left/CardNode
	if (card.owner == players[0] and card.zone == Enum.Zone.STANDBY) or \
		(card.owner == players[1] and card.zone == Enum.Zone.SITUATION):
		display = $QuickDetails/Right
		display_card = $QuickDetails/Right/CardNode
	display.visible = true
	display_card.turn_up()
	display_card.show_card(card.data)
	quick_detail_card = card

func on_hand_card_selected(hand: GameHand, card: Card):
	if not is_free():
		return
	if event_processing():
		get_event().on_hand_card_selected(hand, card)

func _on_zone_selected(field: GameField, zone_owner: Player, zone: Enum.Zone, index: int):
	if not is_free():
		return
	if event_processing():
		get_event().on_zone_selected(field, zone_owner, zone, index)

func _on_end_phase_pressed():
	if not is_free():
		return
	if get_turn_player().has_controller():
		return
	if event_processing():
		get_event().on_end_phase_pressed()

func _on_test_button_pressed():
	pass

func _on_button_exit_pressed():
	for p in players:
		if p.has_controller():
			p.controller.stop()
	get_parent().end_scene()
