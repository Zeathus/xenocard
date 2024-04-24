extends CardEffect

class_name EffectExtraAttack

var damage: int = 0
var filter: CardFilter

func post_init():
	var arg = param.split(",")
	damage = int(arg[0])
	filter = CardFilter.new(arg[1])

func after_attack_turn():
	events.push_back(EventSpecialAttack.new(game_board, card, damage, filter))
