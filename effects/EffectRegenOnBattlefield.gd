extends CardEffect

class_name EffectRegenOnBattlefield

var amount: int = 0

func post_init():
	amount = int(param)

func adjust():
	push_event()

func effect():
	if card.zone == Card.Zone.BATTLEFIELD:
		card.heal(amount)
