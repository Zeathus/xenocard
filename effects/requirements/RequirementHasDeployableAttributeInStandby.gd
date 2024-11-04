extends Requirement

class_name RequirementHasDeployableAttributeInStandby

var players: Array
var attribute: Enum.Attribute

func post_init():
	var params = param.split(",")
	players = [false, false]
	if params[0] == "self":
		players[0] = true
	elif params[0] == "enemy":
		players[1] = true
	elif params[0] == "both" or param == "all":
		players = [true, true]
	attribute = Enum.Attribute[params[1].to_upper()]

func met(variables: Dictionary = {}) -> bool:
	if players[0]:
		for i in range(4):
			var card = effect.host.owner.field.get_card(Enum.Zone.STANDBY, i)
			if card and card.get_attribute() != attribute:
				continue
			if card and card.is_deployable():
				return true
	if players[1]:
		for i in range(4):
			var card = effect.host.owner.get_enemy().field.get_card(Enum.Zone.STANDBY, i)
			if card and card.get_attribute() != attribute:
				continue
			if card and card.is_deployable():
				return true
	return false
