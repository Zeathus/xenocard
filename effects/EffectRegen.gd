extends CardEffect

class_name EffectRegen

var amount: int = 0

func post_init():
	amount = int(param)

func adjust():
	push_event()

func effect():
	card.heal(amount)
