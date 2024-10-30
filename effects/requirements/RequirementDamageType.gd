extends Requirement

class_name RequirementDamageType

var damage_flag: int

func post_init():
	match param:
		"battle":
			damage_flag = Damage.BATTLE
		"normal":
			damage_flag = Damage.NORMAL_ATTACK
		"effect":
			damage_flag = Damage.EFFECT
		"discard":
			damage_flag = Damage.DISCARD
		"destroy":
			damage_flag = Damage.DESTROY
		"penetrating":
			damage_flag = Damage.PENETRATING

func met(variables: Dictionary = {}) -> bool:
	if "source" not in variables:
		return false
	return (variables["source"].flags & damage_flag) != 0
