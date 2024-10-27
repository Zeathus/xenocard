class_name EffectData

var trigger: Enum.Trigger
var requirements: Array[String]
var effects: Array[String]
var ignores_down: bool
var global: bool

func _init(_trigger: Enum.Trigger):
	trigger = _trigger
	requirements = []
	effects = []
	ignores_down = false
	global = false

func instantiate(host: Card) -> CardEffect:
	var instance = CardEffect.new(trigger, host)
	instance.ignores_down = ignores_down
	instance.global = global
	return instance
