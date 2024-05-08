extends CardEffect

class_name EffectSkipBattlePhase

var players: Array

func post_init():
	players = [false, false]
	if param == "self":
		players[0] = true
	elif param == "enemy":
		players[1] = true
	elif param == "both" or param == "all":
		players = [true, true]

func skips_phase(phase: GameBoard.Phase, player: Player):
	if phase != GameBoard.Phase.BATTLE:
		return false
	if players[0] and player == card.owner:
		return true
	if players[1] and player == card.owner.get_enemy():
		return true
	return false
