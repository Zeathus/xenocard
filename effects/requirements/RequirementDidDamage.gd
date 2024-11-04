extends Requirement

class_name RequirementDidDamage

func met(variables: Dictionary = {}) -> bool:
	return "damage" in variables and variables["damage"] > 0
