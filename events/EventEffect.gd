extends Event

class_name EventEffect

var effect: CardEffect
var variables: Dictionary
var targets_required: Array[CardFilter]
var targets: Array[Card] = []
var activated: bool = false
var optional: bool
var cancelled: bool = false
var animate: bool = true
var activations: int = 0

func _init(_game_board: GameBoard, _effect: CardEffect, _variables: Dictionary, _optional=false):
	broadcasted = false
	super(_game_board)
	effect = _effect
	variables = _variables
	optional = _optional
	targets_required = effect.targets_to_select_for_effect()

func get_name() -> String:
	return "Effect"

func on_start():
	if not effect.has_valid_targets(variables):
		finish()
		return
	animate = animate and effect.host.instance and not effect.host.instance.find_child("EffectIndicator").visible
	if animate:
		queue_event(EventAnimation.new(game_board, AnimationEffectStart.new(effect.host)))
	if optional:
		queue_event(EventConfirm.new(
			game_board,
			effect.host.owner,
			effect.get_confirm_message(),
			func(): update_targets(),
			func(): cancelled = true,
			effect.get_help_text()
		))
		return
	if not effect.host.owner.has_controller():
		update_targets()

func on_finish():
	for e in effect.finally:
		e.effect({"self": effect.host})
		for event in effect.events:
			queue_event(event)
		effect.events.clear()
		parent.adopt_children(self)
	effect.host.hide_help_text()
	for t in targets:
		t.deselect()
	game_board.hide_valid_zones()

func update_targets():
	game_board.hide_valid_zones()
	if len(targets) < len(targets_required):
		var filter: CardFilter = targets_required[len(targets)]
		effect.host.owner.field.show_valid_effect_targets(effect, filter)
		effect.host.owner.get_enemy().field.show_valid_effect_targets(effect, filter)

func try_target(card: Card):
	if activations > 0 and card == effect.host:
		if not has_children():
			targets = []
			activated = true
			finish()
		return
	if len(targets) == len(targets_required):
		return
	if card in targets:
		card.deselect()
		targets.erase(card)
	elif len(targets) < len(targets_required):
		if targets_required[len(targets)].is_valid(effect.host.owner, card):
			card.select()
			targets.push_back(card)

func process(delta):
	if pass_to_child("process", [delta]):
		return
	if cancelled:
		if not activated:
			if animate:
				queue_event(EventAnimation.new(game_board, AnimationEffectEnd.new(effect.host)))
			activated = true
		else:
			finish()
	elif len(targets) == len(targets_required):
		if not activated:
			if len(targets) > 0:
				effect.effect_with_targets(targets, variables)
			else:
				effect.effect(variables)
			for event in effect.get_events():
				queue_event(event)
			activated = true
			if animate:
				queue_event(EventAnimation.new(game_board, AnimationEffectEnd.new(effect.host)))
		elif effect.repeatable and not effect.host.owner.has_controller() and effect.has_valid_targets({"self": effect.host}):
			activations += 1
			effect.host.set_help_text("Click to end effect")
			activated = false
			targets = []
		else:
			finish()
	else:
		var player: Player = effect.host.owner
		if player.has_controller() and not player.controller.is_waiting():
			if player.controller.has_response():
				player.controller.receive()
			else:
				player.controller.request(
					[Controller.Action.TARGET],
					[try_target],
					[[targets_required[len(targets)], targets, effect]]
				)

func try_cancel_effect() -> bool:
	if pass_to_child("can_cancel"):
		children = [children[0]]
		pass_to_child("cancel")
		targets = []
		activated = true
		finish()
		return true
	return false

func on_hand_card_selected(hand: GameHand, card: Card):
	if effect.repeatable and card == effect.host and activations > 0:
		if try_cancel_effect():
			return
	if pass_to_child("on_hand_card_selected", [hand, card]):
		return
	if effect.get_controlling_player().has_controller():
		return
	try_target(card)

func on_zone_selected(field: GameField, zone_owner: Player, zone: Enum.Zone, index: int):
	var card = field.get_card(zone, index)
	if effect.repeatable and card == effect.host and activations > 0 and has_children():
		if try_cancel_effect():
			return
	if pass_to_child("on_zone_selected", [field, zone_owner, zone, index]):
		return
	if effect.get_controlling_player().has_controller():
		return
	if card:
		try_target(card)
