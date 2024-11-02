extends Requirement

class_name RequirementFormula

var formula: String = "true"

func post_init():
	formula = Formula.prepare(param, effect.host, effect.get_game_board())

func met(variables: Dictionary = {}) -> bool:
	return Formula.calc(formula, effect.host, effect.get_game_board())
