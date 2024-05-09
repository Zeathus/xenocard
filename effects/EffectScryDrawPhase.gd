extends CardEffect

class_name EffectScryDrawPhase

func on_turn_start():
	push_event()

func effect():
	events.push_back(EventConfirm.new(
		game_board,
		card.owner,
		"Check Top Card of Deck",
		move_to_bottom_of_deck,
		Callable(),
		"Do you want to move this card to the bottom of the deck?",
		card.owner.deck.top()
	))

func move_to_bottom_of_deck():
	card.owner.deck.add_bottom(card.owner.deck.draw(false))
