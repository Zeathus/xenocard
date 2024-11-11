extends Effect

class_name EffectDoubleNonHomingOrPenetratingATK

func get_atk_multiplier(multiplier: float) -> float:
	if target.get_attack_type() != Enum.AttackType.HOMING and not target.penetrates():
		return multiplier * 2
	return multiplier
