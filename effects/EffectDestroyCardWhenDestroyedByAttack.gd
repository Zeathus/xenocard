extends CardEffect

class_name EffectDestroyCardWhenDestroyedByAttack

var filter: CardFilter

func post_init():
	filter = CardFilter.new(param)

func on_destroyed(attacker: Card, source: Damage):
	if source.normal_attack():
		push_event(true)

func targets_to_select_for_effect() -> Array[CardFilter]:
	return [filter]

func handle_effect_targets(targets: Array[Card]):
	for t in targets:
		events.push_back(EventDestroy.new(game_board, card, t, Damage.new(Damage.EFFECT | Damage.DESTROY)))

func has_valid_targets() -> bool:
	for t in game_board.get_all_field_cards():
		if filter.is_valid(card.owner, t):
			return true
	return false
