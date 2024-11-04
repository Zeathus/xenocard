extends Effect

class_name EffectScry1

func effect(variables: Dictionary = {}):
	parent.events.push_back(EventConfirm.new(
		game_board,
		parent.host.owner,
		"Check Top Card of Deck",
		move_to_bottom_of_deck,
		Callable(),
		"Do you want to move this card to the bottom of the deck?",
		parent.host.owner.deck.top()
	))

func move_to_bottom_of_deck():
	parent.host.owner.deck.add_bottom(parent.host.owner.deck.draw(false))

func has_valid_targets(variables: Dictionary = {}) -> bool:
	return parent.host.owner.deck.size() > 0
