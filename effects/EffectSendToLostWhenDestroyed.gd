extends Effect

class_name EffectSendToLostWhenDestroyed

func redirect_when_destroyed(attacker: Card, source: Damage) -> Zone:
	if source.destroy():
		return Zone.LOST
	return super(attacker, source)
