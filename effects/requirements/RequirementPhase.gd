extends Requirement

class_name RequirementPhase

var required_phase: Enum.Phase

func post_init():
	required_phase = Enum.Phase[param.to_upper()]

func met(variables: Dictionary = {}) -> bool:
	if "ignore_phase" in variables and variables["ignore_phase"]:
		return true
	return effect.get_game_board().turn_phase == required_phase
