extends Effect

class_name EffectExtend

var amount: String

func post_init():
	amount = Formula.prepare(param, parent.host, game_board)

func effect(variables: Dictionary = {}):
	parent.duration += Formula.calc(amount, parent.host, game_board)
