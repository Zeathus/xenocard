class_name EffectData

var trigger: Enum.Trigger
var requirements: Array[String]
var effects: Array[String]
var ignores_down: bool
var global: bool
var duration: int
var applied_effect: EffectData

func _init(_trigger: Enum.Trigger):
	trigger = _trigger
	requirements = []
	effects = []
	ignores_down = false
	global = false
	duration = -1
	applied_effect = null

func instantiate(host: Card) -> CardEffect:
	var instance = CardEffect.new(trigger, host)
	instance.ignores_down = ignores_down
	instance.global = global
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
		var req = Requirement.parse(i).new(instance)
		instance.requirements.push_back(req)
	return instance

static func parse(data, card_name) -> EffectData:
	if data is String:
		return null
	if "trigger" not in data:
		print("Trigger missing for effect for card '%s'" % card_name)
		return null
	if data["trigger"].to_upper() not in Enum.Trigger:
		print("Invalid effect Trigger '%s' for card '%s'" % [data["trigger"].to_upper(), card_name])
		return null
	if "effect" not in data:
		print("Effect missing for effect for card '%s'" % card_name)
		return null
	var effect_data = EffectData.new(Enum.Trigger[data["trigger"].to_upper()])
	for e in data["effect"]:
		if true: # validity check
			effect_data.effects.push_back(e)
	if "requirement" in data:
		for r in data["requirement"]:
			if true: # validity check
				effect_data.requirements.push_back(r)
	if "ignores_down" in data:
		effect_data.ignores_down = data["ignores_down"]
	if "global" in data:
		effect_data.global = data["global"]
	if "stackable" in data:
		effect_data.stackable = data["stackable"]
	if "duration" in data:
		effect_data.duration = data["duration"]
	if "applied_effect" in data:
		effect_data.applied_effect = EffectData.parse(data["applied_effect"], card_name)
	return effect_data
