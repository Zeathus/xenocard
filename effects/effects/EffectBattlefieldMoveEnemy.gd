extends Effect

class_name EffectBattlefieldMoveEnemy

var from: int
var to: int

func post_init():
	var params = param.split(",")
	from = int(params[0]) - 1
	to = int(params[1]) - 1

func effect(variables: Dictionary = {}):
	var from_card = parent.host.owner.get_enemy().field.get_card(Enum.Zone.BATTLEFIELD, from)
	var to_card = parent.host.owner.get_enemy().field.get_card(Enum.Zone.BATTLEFIELD, to)
	if from_card:
		parent.events.push_back(EventAutoMove.new(game_board, from_card.owner, from_card, Enum.Zone.BATTLEFIELD, to))
	elif to_card:
		parent.events.push_back(EventAutoMove.new(game_board, to_card.owner, to_card, Enum.Zone.BATTLEFIELD, from))
