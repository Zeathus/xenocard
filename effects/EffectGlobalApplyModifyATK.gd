extends Effect

class_name EffectGlobalApplyModifyATK

var amount: int
var time: int
var filter: CardFilter

func post_init():
	var arg = param.split(",")
	amount = int(arg[0])
	time = int(arg[1])
	filter = CardFilter.new(arg[2])

func effect():
	for c in game_board.get_all_field_cards():
		if not filter.is_valid(card.owner, c):
			continue
		var effect = EffectModifyATK.new(game_board, c, "%d" % amount)
		effect.duration = time
		c.applied_effects.push_back(effect)
