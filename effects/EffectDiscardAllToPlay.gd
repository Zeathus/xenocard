extends CardEffect

class_name EffectDiscardAllToPlay

var filter: CardFilter

func post_init():
	filter = CardFilter.new(param)

func can_replace_card(card: Card) -> bool:
	return filter.is_valid(self.card.owner, card)

func handle_set_targets(targets: Array[Card]):
	for target in game_board.get_all_field_cards():
		if card != target and filter.is_valid(card.owner, target):
			events.push_back(EventDestroy.new(get_game_board(), card, target, Damage.new(Damage.EFFECT | Damage.DISCARD)))
