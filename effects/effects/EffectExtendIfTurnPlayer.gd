extends Effect

class_name EffectExtendIfTurnPlayer

var player: int

func post_init():
	if param == "self":
		player = 0
	elif param == "enemy":
		player = 1

func effect(variables: Dictionary = {}):
	if game_board.turn_player_id == parent.host.owner.id:
		if player == 0:
			parent.duration += 1
	else:
		if player == 1:
			parent.duration += 1
