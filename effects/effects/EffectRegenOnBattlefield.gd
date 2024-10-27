extends Effect

class_name EffectRegenOnBattlefield

var amount: int = 0

func post_init():
	amount = int(param)

func adjust():
	push_event()

func effect():
	if card.zone == Enum.Zone.BATTLEFIELD:
		card.heal(amount)
