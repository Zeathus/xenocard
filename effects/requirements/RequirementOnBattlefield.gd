extends Requirement

class_name RequirementOnBattlefield

func met() -> bool:
	return effect.host.zone == Enum.Zone.BATTLEFIELD
