extends Effect

class_name EffectPreventHomingAttacks

func attack_stopped() -> bool:
	return target.get_attack_type() == Enum.AttackType.HOMING
