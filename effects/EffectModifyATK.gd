extends CardEffect

class_name EffectModifyATK

var amount: int = 0

func post_init():
	amount = int(param)

func get_atk(atk: int) -> int:
	atk += amount
	return atk
