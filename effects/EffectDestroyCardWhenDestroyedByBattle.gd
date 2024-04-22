extends CardEffect

class_name EffectDestroyCardWhenDestroyedByBattle

var filter: CardFilter

func post_init():
	filter = CardFilter.new(param)

func on_destroyed(attacker: Card, source: Card.DamageSource):
	if source == Card.DamageSource.BATTLE:
		events.push_back(EventEffect.new(get_game_board(), self, true))

func targets_to_select_for_effect() -> Array[CardFilter]:
	return [filter]

func handle_effect_targets(targets: Array[Card]):
	for t in targets:
		events.push_back(EventDestroy.new(get_game_board(), card, t, Card.DamageSource.EFFECT))

func has_valid_targets() -> bool:
	for t in game_board.get_all_field_cards():
		if filter.is_valid(card.owner, t):
			return true
	return false
