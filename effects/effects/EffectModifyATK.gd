extends Effect

class_name EffectModifyATK

var formula: String = "0"

func post_init():
	formula = Formula.prepare(param, parent.host, parent.get_game_board())

func get_atk(atk: int) -> int:
	atk += Formula.calc(formula, parent.host, parent.get_game_board())
	return atk
