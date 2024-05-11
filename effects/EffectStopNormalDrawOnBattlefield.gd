extends CardEffect

class_name EffectStopNormalDrawOnBattlefield

func stops_normal_draw() -> bool:
	return card.zone == Enum.Zone.BATTLEFIELD
