extends CardEffect

class_name EffectRecoverOnAdjust

var amount: int

func post_init():
	amount = int(param)

func adjust():
	if card.owner.lost.size() > 0:
		push_event()

func effect():
	var recovered = card.owner.recover(amount)
	for i in range(recovered):
		events.push_back(EventRecover.new(card.owner.game_board, card.owner))
