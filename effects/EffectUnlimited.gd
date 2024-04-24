extends CardEffect

class_name EffectUnlimited

func is_active() -> bool:
	return true

func uses_one_card_per_turn(value: bool) -> bool:
	return false
