extends Requirement

class_name RequirementHasWeapon

func met() -> bool:
	var holder = effect.get_user()
	return bool(holder.equipped_weapon)
