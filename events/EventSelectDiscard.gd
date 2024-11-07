extends Event

class_name EventSelectDiscard

var player: Player
var in_sub_event: bool = false
var filter: CardFilter
var cause: Card

func _init(_game_board: GameBoard, _player: Player, _filter: CardFilter = null, _cause: Card = null):
	super(_game_board)
	player = _player
	filter = _filter
	cause = _cause

func get_name() -> String:
	return "SelectDiscard"

func on_start():
	if not player.has_controller():
		show_selectable()

func on_finish():
	hide_selectable()

func can_cancel() -> bool:
	return not has_children()

func process(delta):
	if pass_to_child("process", [delta]):
		return
	if in_sub_event:
		finish()
		return
	if player.has_controller() and not player.controller.is_waiting():
		if player.controller.has_response():
			player.controller.receive()
		else:
			player.controller.request(
				[Controller.Action.DISCARD],
				[func(c): discard_card(c); in_sub_event = true],
				[[filter]]
			)

func on_hand_card_selected(hand: GameHand, card: Card):
	if pass_to_child("on_hand_card_selected", [hand, card]):
		return
	if player.has_controller():
		return
	if not filter or filter.is_valid(player, card):
		hide_selectable()
		queue_event(EventDestroy.new(game_board, cause if cause else card, card, Damage.new(Damage.DISCARD)))
		in_sub_event = true

func on_zone_selected(field: GameField, zone_owner: Player, zone: Enum.Zone, index: int):
	if pass_to_child("on_zone_selected", [field, zone_owner, zone, index]):
		return
	if player.has_controller():
		return
	var card: Card = field.get_card(zone, index)
	if card and (not filter or filter.is_valid(player, card)):
		hide_selectable()
		queue_event(EventDestroy.new(game_board, cause if cause else card, card, Damage.new(Damage.DISCARD)))
		in_sub_event = true

func discard_card(card: Card):
	queue_event(EventDestroy.new(game_board, cause if cause else card, card, Damage.new(Damage.DISCARD)))

func show_selectable():
	for card in player.hand.cards:
		var valid: bool = filter.is_valid(player, card)
		card.set_selectable(valid)
	for card in player.field.get_all_cards():
		var valid: bool = filter.is_valid(player, card)
		card.set_selectable(valid)

func hide_selectable():
	for card in player.hand.cards:
		card.set_selectable(false)
	for card in player.field.get_all_cards():
		card.set_selectable(false)
