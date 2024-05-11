extends Effect

class_name EffectDrawCardFirstAdjustPhase

func adjust():
	if card.turn_count == 0 and card.owner.can_draw():
		push_event()

func effect():
	events.push_back(EventDrawCard.new(card.owner.game_board, card.owner))
