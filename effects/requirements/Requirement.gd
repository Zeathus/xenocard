class_name Requirement

var effect: CardEffect

func _init(_effect: CardEffect):
	effect = _effect

func met() -> bool:
	return true

static func parse(effect: String) -> Object:
	var effect_script: GDScript = load("res://effects/requirements/Requirement%s.gd" % effect)
	if effect_script == null:
		print("Failed to find effect requirement '%s'" % effect)
		return Requirement
	return effect_script
