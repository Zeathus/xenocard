extends Requirement

class_name RequirementPhase

var required_phase: Enum.Phase

func post_init():
	required_phase = Enum.Phase[param.to_upper()]

func met(variables: Dictionary = {}) -> bool:
	return effect.get_game_board().turn_phase == required_phase
