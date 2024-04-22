extends CardEffect

class_name EffectPreventHomingAttacks

func attack_stopped() -> bool:
	return card.get_target() == Card.Target.HOMING
