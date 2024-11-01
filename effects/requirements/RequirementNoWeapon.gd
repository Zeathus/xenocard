extends Requirement

class_name RequirementNoWeapon

func met(variables: Dictionary = {}) -> bool:
	var holder = effect.get_user()
	return holder.equipped_weapon == null
