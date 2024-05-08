extends Event

class_name EventEffect

var effect: CardEffect
var targets_required: Array[CardFilter]
var targets: Array[Card] = []
var activated: bool = false
var optional: bool
var cancelled: bool = false

func _init(_game_board: GameBoard, _effect: CardEffect, _optional=false):
	super(_game_board)
	effect = _effect
	optional = _optional
	targets_required = effect.targets_to_select_for_effect()

func get_name() -> String:
	return "Effect"

func on_start():
	if not effect.has_valid_targets():
		finish()
		return
	queue_event(EventAnimation.new(game_board, AnimationEffectStart.new(effect.host)))
	if optional:
		queue_event(EventConfirm.new(
			game_board,
			effect.card.owner,
			effect.get_confirm_message(),
			func(): update_targets(),
			func(): cancelled = true,
			effect.get_help_text()
		))
		return
	if not effect.card.owner.has_controller():
		update_targets()

func on_finish():
	for t in targets:
		t.deselect()
	game_board.hide_valid_zones()

func update_targets():
	game_board.hide_valid_zones()
	if len(targets) < len(targets_required):
		var filter: CardFilter = targets_required[len(targets)]
		effect.card.owner.field.show_valid_effect_targets(effect, filter)
		effect.card.owner.get_enemy().field.show_valid_effect_targets(effect, filter)

func try_target(card: Card):
	if len(targets) == len(targets_required):
		return
	if card in targets:
		card.deselect()
		targets.erase(card)
	elif len(targets) < len(targets_required):
		if targets_required[len(targets)].is_valid(effect.card.owner, card):
			card.select()
			targets.push_back(card)

func process(delta):
	if pass_to_child("process", [delta]):
		return
	if cancelled:
		if not activated:
			queue_event(EventAnimation.new(game_board, AnimationEffectEnd.new(effect.host)))
			activated = true
		else:
			finish()
	elif len(targets) == len(targets_required):
		if not activated:
			effect.handle_effect_targets(targets)
			effect.effect()
			for event in effect.get_events():
				queue_event(event)
			activated = true
			queue_event(EventAnimation.new(game_board, AnimationEffectEnd.new(effect.host)))
		else:
			finish()
	else:
		var player: Player = effect.card.owner
		if player.has_controller() and not player.controller.is_waiting():
			if player.controller.has_response():
				player.controller.receive()
			else:
				player.controller.request(
					[Controller.Action.TARGET],
					[try_target],
					[[targets_required[len(targets)], targets]]
				)

func on_hand_card_selected(hand: GameHand, card: Card):
	if pass_to_child("on_hand_card_selected", [hand, card]):
		return
	if effect.get_controlling_player().has_controller():
		return
	try_target(card)

func on_zone_selected(field: GameField, zone_owner: Player, zone: Card.Zone, index: int):
	if pass_to_child("on_zone_selected", [field, zone_owner, zone, index]):
		return
	if effect.get_controlling_player().has_controller():
		return
	var card = field.get_card(zone, index)
	if card:
		try_target(card)
