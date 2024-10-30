extends Requirement

class_name RequirementAloneOnBattlefield

func met(variables: Dictionary = {}) -> bool:
	if effect.host.zone != Enum.Zone.BATTLEFIELD:
		return false
	for c in effect.host.owner.field.get_battlefield_cards():
		if c != effect.host:
			return false
	return true
