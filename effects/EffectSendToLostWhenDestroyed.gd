extends CardEffect

class_name EffectSendToLostWhenDestroyed

func redirect_when_destroyed(attacker: Card, source: Damage) -> Enum.Zone:
	if source.destroy():
		return Enum.Zone.LOST
	return super(attacker, source)
