class_name EffectData

var trigger: Enum.Trigger
var requirements: Array[String]
var effects: Array[String]

func _init(_trigger: Enum.Trigger):
	trigger = _trigger
	requirements = []
	effects = []

#func instantiate() -> Effect:
	
