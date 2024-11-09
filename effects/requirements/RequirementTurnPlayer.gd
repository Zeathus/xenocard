extends Requirement

class_name RequirementTurnPlayer

var player: int

func post_init():
	if param == "self":
		player = 0
	elif param == "enemy":
		player = 1

func met(variables: Dictionary = {}) -> bool:
	if effect.get_game_board().turn_player_id == effect.host.owner.id:
		return player == 0
	else:
		return player == 1
