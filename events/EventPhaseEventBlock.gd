extends Event

class_name EventPhaseEventBlock

var player: Player
var phase_effects: Array
var block: bool
var in_sub_event: bool = false

func _init(_game_board: GameBoard, _player: Player, _phase_effects: Array, _block: bool = false):
	super(_game_board)
	player = _player
	block = _block

func get_name() -> String:
	return "PhaseEvent"

func on_start():
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
			var action = Controller.Action.BLOCK if block else Controller.Action.EVENT
			player.controller.request(
				[action, Controller.Action.END_PHASE],
				[activate_card, on_end_phase_pressed]
			)

func show_selectable():
	for card in player.hand.cards:
		var valid: bool = card.selectable(game_board)
		card.set_selectable(valid)
	for card in player.field.get_all_cards():
		var valid: bool = card.selectable(game_board)
		card.set_selectable(valid)

func hide_selectable():
	for card in player.hand.cards:
		card.set_selectable(false)
	for card in player.field.get_all_cards():
		card.set_selectable(false)

func activate_card(card: Card):
	if card.zone == Enum.Zone.HAND:
		on_hand_card_selected(card.owner.hand, card)
	else:
		on_zone_selected(card.owner.field, card.owner, card.zone, card.zone_index)

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
	var card: Card = field.get_card(zone, index)
	if card and card.selectable(game_board):
		hide_selectable()
		queue_event(EventAnimation.new(game_board, AnimationEffectStart.new(card)))
		card.trigger_effects(Enum.Trigger.ACTIVATE, self, {"block": block})
		queue_event(EventAnimation.new(game_board, AnimationEffectEnd.new(card)))
		in_sub_event = true

func on_end_phase_pressed():
	if not has_children():
		if player.can_end_phase(Enum.Phase.BLOCK):
			finish()
