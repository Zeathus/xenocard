extends Effect

class_name EffectModifyMaxHP

var formula: String = "0"

func post_init():
	formula = Formula.prepare(param, parent.host, parent.get_game_board())

func get_max_hp(max_hp: int) -> int:
	max_hp += Formula.calc(formula, parent.host, parent.get_game_board())
	return max_hp
