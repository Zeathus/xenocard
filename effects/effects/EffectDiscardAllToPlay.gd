extends Effect

class_name EffectDiscardAllToPlay

var filter: CardFilter

func post_init():
	filter = CardFilter.new(param)

func skips_e_mark() -> bool:
	return true

func can_replace_card(card: Card) -> bool:
	return filter.is_valid(self.card.owner, card)

func handle_set_targets(targets: Array[Card]):
	for target in game_board.get_all_field_cards():
		if parent.host != target and filter.is_valid(parent.host.owner, target):
			parent.events.push_back(EventDestroy.new(parent.get_game_board(), parent.host, target, Damage.new(Damage.EFFECT | Damage.DISCARD)))
