extends CardEffect

class_name EffectPlayToZoneWith1HP

var zone: Card.Zone
var zone_index: int

func post_init():
	var arg = param.split(",")
	zone = int(arg[0])
	zone_index = int(arg[1])

func effect():
	card.modify_for_set.push_back(func(x):
		x.hp = 1
	)
	var set_event = EventAutoSet.new(game_board, card.owner, card, zone, zone_index)
	events.push_back(set_event)
