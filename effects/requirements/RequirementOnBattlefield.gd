extends Requirement

class_name RequirementOnBattlefield

func met(variables: Dictionary = {}) -> bool:
	return effect.host.zone == Enum.Zone.BATTLEFIELD
