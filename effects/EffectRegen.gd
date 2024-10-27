extends CardEffect

class_name EffectRegen

var amount: int = 0

func post_init():
	amount = int(param)

func adjust():
	if card.hp < card.get_max_hp():
		push_event()

func effect():
	card.heal(amount)
