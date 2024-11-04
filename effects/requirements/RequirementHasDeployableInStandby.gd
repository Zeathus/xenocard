extends Requirement

class_name RequirementHasDeployableInStandby

var players: Array

func post_init():
	players = [false, false]
	if param == "self":
		players[0] = true
	elif param == "enemy":
		players[1] = true
	elif param == "both" or param == "all":
		players = [true, true]

func met(variables: Dictionary = {}) -> bool:
	if players[0]:
		for i in range(4):
			var card = effect.host.owner.field.get_card(Enum.Zone.STANDBY, i)
			if card and card.is_deployable():
				return true
	if players[1]:
		for i in range(4):
			var card = effect.host.owner.get_enemy().field.get_card(Enum.Zone.STANDBY, i)
			if card and card.is_deployable():
				return true
	return false
