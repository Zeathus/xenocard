extends CardEffect

class_name EffectDrawPhaseDrawFromLostOnBattlefield

var amount: int = 1

func post_init():
	if param != "":
		amount = int(param)

func after_normal_draw():
	push_event()

func effect():
	if card.zone == Card.Zone.BATTLEFIELD:
		for i in range(amount):
			events.push_back(EventDrawCardFromLost.new(game_board, card.owner))
