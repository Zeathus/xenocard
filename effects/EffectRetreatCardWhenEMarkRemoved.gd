extends CardEffect

class_name EffectRetreatCardWhenEMarkRemoved

var filter: CardFilter

func post_init():
	filter = CardFilter.new(param)

func on_e_mark_removed():
	if len(card.owner.field.get_standby_cards()) < 4:
		events.push_back(EventEffect.new(get_game_board(), self, true))

func targets_to_select_for_effect() -> Array[CardFilter]:
	return [filter]

func handle_effect_targets(targets: Array[Card]):
	for t in targets:
		for i in range(4):
			if t.owner.field.get_card(Card.Zone.STANDBY, i) == null:
				events.push_back(EventAutoMove.new(game_board, t.owner, t, Card.Zone.STANDBY, i))
				break

func has_valid_targets() -> bool:
	for t in game_board.get_all_battlefield_cards():
		if filter.is_valid(card.owner, t):
			return true
	return false
