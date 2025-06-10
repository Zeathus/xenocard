extends Event

class_name EventPhaseSet

var player: Player
var phase_effects: Array
var in_sub_event: bool = false

func _init(_game_board: GameBoard, _player: Player, _phase_effects: Array):
	super(_game_board)
	player = _player

func get_name() -> String:
	return "PhaseSet"

func on_start():
	broadcast_player(player)
	queue_event(EventStartPhase.new(game_board, player, Enum.Phase.SET))
	if not player.has_controller():
		show_selectable()

func on_finish():
	hide_selectable()
	game_board.end_phase()

func process(delta):
	if pass_to_child("process", [delta]):
		return
	if in_sub_event:
		in_sub_event = false
		show_selectable()
	if player.has_controller() and not player.controller.is_waiting():
		if player.controller.has_response():
			player.controller.receive()
		else:
			player.controller.request(
				[Controller.Action.SET, Controller.Action.END_PHASE],
				[set_card, on_end_phase_pressed]
			)

func on_hand_card_selected(hand: GameHand, card: Card):
	if pass_to_child("on_hand_card_selected", [hand, card]):
		return
	if player.has_controller():
		return
	if card.selectable(game_board):
		hide_selectable()
		queue_event(EventSet.new(game_board, player, card))
		in_sub_event = true

func on_zone_selected(field: GameField, zone_owner: Player, zone: Enum.Zone, index: int):
	if pass_to_child("on_zone_selected", [field, zone_owner, zone, index]):
		return
	if player.has_controller():
		return

func set_card(card: Card, zone: Enum.Zone, index: int, targets: Array[Card]):
	var set_event: EventSet = EventSet.new(game_board, player, card)
	if not player.is_online():
		for t in targets:
			t.select()
		set_event.targets = targets
		set_event.on_zone_selected(player.field, player, zone, index)
	queue_event(set_event)

func on_end_phase_pressed():
	if can_end_phase():
		if player.get_enemy().is_online():
			player.get_enemy().controller.send_action(Controller.Action.END_PHASE)
		finish()

func can_end_phase():
	return started and (not has_children()) and player.can_end_phase(Enum.Phase.SET)

func show_selectable():
	for card in player.hand.cards:
		var valid: bool = card.selectable(game_board)
		card.set_selectable(valid)

func hide_selectable():
	for card in player.hand.cards:
		card.set_selectable(false)
