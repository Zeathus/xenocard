extends Effect

class_name EffectExtraAttack

var damage: int = 0
var filter: CardFilter

func post_init():
	var arg = param.split(",")
	damage = int(arg[0])
	filter = CardFilter.new(arg[1])

func effect(variables: Dictionary = {}):
	parent.events.push_back(EventSpecialAttack.new(game_board, parent.host, damage, filter))
