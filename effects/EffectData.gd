class_name EffectData

var trigger: Enum.Trigger
var requirements: Array[String]
var effects: Array[String]
var ignores_down: bool
var global: CardFilter
var optional: bool
var stackable: bool
var animated: bool
var repeatable: bool
var duration: int
var applied_effect: EffectData
var effects_on_end: Array[String]
var finally: Array[String]

func _init(_trigger: Enum.Trigger):
	trigger = _trigger
	requirements = []
	effects = []
	ignores_down = false
	global = null
	optional = false
	stackable = true
	animated = true
	repeatable = false
	duration = -1
	applied_effect = null
	effects_on_end = []
	finally = []

func instantiate(host: Card) -> CardEffect:
	var instance = CardEffect.new(trigger, host)
	instance.ignores_down = ignores_down
	instance.global = global
	instance.optional = optional
	instance.stackable = stackable
	instance.animated = animated
	instance.repeatable = repeatable
	instance.duration = duration
	instance.applied_effect = applied_effect
	for i in effects:
		var param: String = ""
		if "(" in i and ")" in i and i.find("(") < i.rfind(")"):
			param = i.substr(i.find("(") + 1, i.rfind(")") - i.find("(") - 1)
			i = i.substr(0, i.find("("))
		var effect = Effect.parse(i).new(instance, host.owner.game_board, host, param)
		instance.effects.push_back(effect)
	for i in requirements:
		var param: String = ""
		if "(" in i and ")" in i and i.find("(") < i.rfind(")"):
			param = i.substr(i.find("(") + 1, i.rfind(")") - i.find("(") - 1)
			i = i.substr(0, i.find("("))
		var req = Requirement.parse(i).new(instance, param)
		instance.requirements.push_back(req)
	for i in effects_on_end:
		var param: String = ""
		if "(" in i and ")" in i and i.find("(") < i.rfind(")"):
			param = i.substr(i.find("(") + 1, i.rfind(")") - i.find("(") - 1)
			i = i.substr(0, i.find("("))
		var effect = Effect.parse(i).new(instance, host.owner.game_board, host, param)
		instance.effects_on_end.push_back(effect)
	for i in finally:
		var param: String = ""
		if "(" in i and ")" in i and i.find("(") < i.rfind(")"):
			param = i.substr(i.find("(") + 1, i.rfind(")") - i.find("(") - 1)
			i = i.substr(0, i.find("("))
		var effect = Effect.parse(i).new(instance, host.owner.game_board, host, param)
		instance.finally.push_back(effect)
	return instance

static func parse(data, card_name) -> EffectData:
	if data is String:
		return null
	if "trigger" not in data:
		Logger.e("Trigger missing for effect for card '%s'" % card_name)
		return null
	if data["trigger"].to_upper() not in Enum.Trigger:
		Logger.e("Invalid effect Trigger '%s' for card '%s'" % [data["trigger"].to_upper(), card_name])
		return null
	if "effect" not in data:
		Logger.e("Effect missing for effect for card '%s'" % card_name)
		return null
	var effect_data = EffectData.new(Enum.Trigger[data["trigger"].to_upper()])
	for e in data["effect"]:
		if EffectData.exists("effects", "Effect", e): # validity check
			effect_data.effects.push_back(e)
		else:
			Logger.e("Failed to find effect '%s' for card '%s'" % [e, card_name])
	if "requirement" in data:
		for r in data["requirement"]:
			if EffectData.exists("requirements", "Requirement", r): # validity check
				effect_data.requirements.push_back(r)
			else:
				Logger.e("Failed to find requirement '%s' for card '%s'" % [r, card_name])
	if "on_end" in data:
		for e in data["on_end"]:
			if EffectData.exists("effects", "Effect", e): # validity check
				effect_data.effects_on_end.push_back(e)
			else:
				Logger.e("Failed to find effect '%s' for card '%s'" % [e, card_name])
	if "finally" in data:
		for e in data["finally"]:
			if EffectData.exists("effects", "Effect", e): # validity check
				effect_data.finally.push_back(e)
			else:
				Logger.e("Failed to find effect '%s' for card '%s'" % [e, card_name])
	if "ignores_down" in data:
		effect_data.ignores_down = data["ignores_down"]
	if "global" in data:
		effect_data.global = CardFilter.new(data["global"])
	if "optional" in data:
		effect_data.optional = data["optional"]
	if "stackable" in data:
		effect_data.stackable = data["stackable"]
	if "animated" in data:
		effect_data.animated = data["animated"]
	if "repeatable" in data:
		effect_data.repeatable = data["repeatable"]
	if "duration" in data:
		effect_data.duration = data["duration"]
	if "applied_effect" in data:
		effect_data.applied_effect = EffectData.parse(data["applied_effect"], card_name)
	return effect_data

static func exists(folder: String, category: String, definition: String) -> bool:
	if "(" in definition:
		definition = definition.substr(0,definition.find("("))
	var script: GDScript = load("res://effects/%s/%s%s.gd" % [folder, category, definition])
	return script != null
