extends CardEffect

class_name EffectSendToLostWhenDestroyed

func redirect_when_destroyed(attacker: Card, source: Damage) -> Card.Zone:
	if source.destroy():
		return Card.Zone.LOST
	return super(attacker, source)
