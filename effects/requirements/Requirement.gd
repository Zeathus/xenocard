class_name Requirement

var effect: CardEffect
var param: String

func _init(_effect: CardEffect, _param: String = ""):
	effect = _effect
	param = _param
	post_init()

func post_init():
	pass

func met(variables: Dictionary = {}) -> bool:
	return true

static func parse(effect: String) -> Object:
	var effect_script: GDScript = load("res://effects/requirements/Requirement%s.gd" % effect)
	if effect_script == null:
		Logger.e("Failed to find effect requirement '%s'" % effect)
		return Requirement
	return effect_script
