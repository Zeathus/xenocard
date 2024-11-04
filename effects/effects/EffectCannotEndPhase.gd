extends Effect

class_name EffectCannotEndPhase

var blocked_phase: Enum.Phase
var players: Array

func post_init():
	var params = param.split(",")
	blocked_phase = Enum.Phase[params[0].to_upper()]
	players = [false, false]
	if params[1] == "self":
		players[0] = true
	elif params[1] == "enemy":
		players[1] = true
	elif params[1] == "both" or param == "all":
		players = [true, true]

func can_end_phase(phase: Enum.Phase, player: Player) -> bool:
	if blocked_phase != phase:
		return true
	if players[0] and parent.host.owner == player:
		return false
	if players[1] and parent.host.owner.get_enemy() == player:
		return false
	return true
