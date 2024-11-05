extends Effect

class_name EffectPlayToZoneWith1HP

var zone: Enum.Zone
var zone_index: int

func post_init():
	var arg = param.split(",")
	zone = arg[0]
	zone_index = int(arg[1])

func effect(variables: Dictionary = {}):
	target.modify_for_set.push_back(func(x):
		x.hp = 1
	)
	var set_event = EventAutoSet.new(game_board, target.owner, target, zone, zone_index)
	parent.events.push_back(set_event)
