extends Node2D

class_name GameBoard

enum Phase {DRAW, MOVE, EVENT, SET, BLOCK, BATTLE, ADJUST}

var quick_details_enabled: bool = true
var quick_detail_card: Card = null
var quick_detail_card_timer: float = 0

var players: Array[Player]
var turn_player_id: int = 0
var turn_phase: Phase = Phase.DRAW
var card_zones: Array[Node2D]
var card_held: Node2D
var event_queue: Array[Event]
var free_menu = null
var phase_effects: Dictionary
var player_options: Array[Dictionary] = []
var game_options: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in Phase:
		phase_effects[Phase[i]] = []
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
			free_menu.finish()
			free_menu = null
	elif event_processing():
		var event = get_event()
		event.process(delta)
		if event.is_done():
			event_queue.pop_front()
		return
	#if card_held:
		#card_held.global_position = get_global_mouse_position()
		#if Input.is_action_just_released("left_click"):
			#_on_card_dropped(card_held)

func add_menu(menu, z_index=0):
	menu.z_index = z_index
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

func skips_phase(phase: Phase, player: Player):
	for card in get_all_field_cards():
		for e in card.get_effects():
			if e.skips_phase(phase, player):
				return true
	return false

func begin_phase(phase: Phase):
	turn_phase = phase
	var player: Player = get_turn_player()
	if skips_phase(turn_phase, player):
		end_phase()
		return
	match turn_phase:
		Phase.DRAW:
			$Phases/Phase/Label.text = "%dP Draw Phase" % (turn_player_id + 1)
			queue_event(EventPhaseDraw.new(self, player, phase_effects[Phase.DRAW]))
		Phase.MOVE:
			$Phases/Phase/Label.text = "%dP Move Phase" % (turn_player_id + 1)
			queue_event(EventPhaseMove.new(self, player, phase_effects[Phase.MOVE]))
		Phase.EVENT:
			$Phases/Phase/Label.text = "%dP Event Phase" % (turn_player_id + 1)
			queue_event(EventPhaseEvent.new(self, player, phase_effects[Phase.EVENT]))
		Phase.SET:
			$Phases/Phase/Label.text = "%dP Set Phase" % (turn_player_id + 1)
			queue_event(EventPhaseSet.new(self, player, phase_effects[Phase.SET]))
		Phase.BLOCK:
			$Phases/Phase/Label.text = "%dP Block Phase" % ((turn_player_id + 1) % 2 + 1)
			queue_event(EventPhaseBlock.new(self, player, phase_effects[Phase.BLOCK]))
		Phase.BATTLE:
			$Phases/Phase/Label.text = "%dP Battle Phase" % (turn_player_id + 1)
			queue_event(EventPhaseBattle.new(self, player, phase_effects[Phase.BATTLE]))
		Phase.ADJUST:
			$Phases/Phase/Label.text = "%dP Adjust Phase" % (turn_player_id + 1)
			queue_event(EventPhaseAdjust.new(self, player, phase_effects[Phase.ADJUST]))

func end_phase():
	match turn_phase:
		Phase.DRAW:
			begin_phase(Phase.MOVE)
		Phase.MOVE:
			begin_phase(Phase.EVENT)
		Phase.EVENT:
			begin_phase(Phase.SET)
		Phase.SET:
			begin_phase(Phase.BLOCK)
		Phase.BLOCK:
			begin_phase(Phase.BATTLE)
		Phase.BATTLE:
			begin_phase(Phase.ADJUST)
		Phase.ADJUST:
			next_player()
			begin_turn()
	refresh()

func begin_turn():
	var turn_player: Player = get_turn_player()
	turn_player.used_one_battle_card_per_turn = false
	turn_player.used_one_situation_card_per_turn = false
	begin_phase(Phase.DRAW)

func refresh():
	for player in [get_turn_player(), get_turn_enemy()]:
		player.field.refresh()
		player.set_reveal_hand(false)
		for card in get_all_field_cards():
			for e in card.get_effects():
					var reveal_hand = e.reveal_hand(player)
					if reveal_hand:
						player.set_reveal_hand(reveal_hand)

func next_player():
	turn_player_id = (turn_player_id + 1) % 2

func prepare_card(card: Card) -> Card:
	card.reset()
	card.instance.show_details.connect(_on_card_show_details)
	card.instance.on_hover.connect(_on_card_hovered)
	return card

func get_turn_player() -> Player:
	var player_id: int = turn_player_id
	if turn_phase == Phase.BLOCK:
		player_id = (player_id + 1) % 2
	return players[turn_player_id]

func get_turn_enemy() -> Player:
	return players[(turn_player_id + 1) % 2]

func hide_valid_zones():
	get_turn_player().field.hide_valid_zones()
	get_turn_enemy().field.hide_valid_zones()

func get_all_field_cards() -> Array[Card]:
	var result: Array[Card] = []
	for p in players:
		result += p.field.get_all_cards()
	return result

func get_all_battlefield_cards() -> Array[Card]:
	var result: Array[Card] = []
	for p in players:
		result += p.field.get_battlefield_cards()
	return result

func add_phase_effect(phase: Phase, effect: CardEffect):
	phase_effects[phase].push_back(effect)

func _on_card_grabbed(card: Node2D):
	card_held = card

func _on_card_dropped(card: Node2D):
	var hovered_areas = $Mouse.get_overlapping_areas()
	for node in card_zones:
		var area: Area2D = node.find_child("Area")
		if area in hovered_areas:
			get_turn_player().field.snap_card_to_zone(card.card, node)
			break
	card_held = null

func _on_card_show_details(card):
	$CardDetails.visible = true
	$CardDetails/Card.turn_up()
	$CardDetails/Card.load_card(card)

func _on_card_hovered(card):
	$QuickDetails/Left.visible = false
	$QuickDetails/Right.visible = false
	var display = $QuickDetails/Left
	var display_card = $QuickDetails/Left/Card
	if (card.owner == players[0] and card.zone == Card.Zone.STANDBY) or \
		(card.owner == players[1] and card.zone == Card.Zone.SITUATION):
		display = $QuickDetails/Right
		display_card = $QuickDetails/Right/Card
	display.visible = true
	display_card.turn_up()
	display_card.load_card(card)
	quick_detail_card = card

func on_hand_card_selected(hand: GameHand, card: Card):
	if not is_free():
		return
	if event_processing():
		get_event().on_hand_card_selected(hand, card)

func _on_zone_selected(field: GameField, zone_owner: Player, zone: Card.Zone, index: int):
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
