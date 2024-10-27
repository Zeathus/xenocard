extends CardEffect

class_name EffectGaignun

# When the E mark is removed from this card, all {Realians}
# on the battlefield go back to their owners' hands.

func on_e_mark_removed():
	push_event()

func effect():
	for c in game_board.get_all_battlefield_cards():
		if c.get_attribute() == Enum.Attribute.REALIAN:
			events.push_back(EventFieldToHand.new(game_board, c))
