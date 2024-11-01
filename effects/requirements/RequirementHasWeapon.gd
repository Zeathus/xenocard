extends Requirement

class_name RequirementHasWeapon

func met(variables: Dictionary = {}) -> bool:
	var holder = effect.get_user()
	return bool(holder.equipped_weapon)
