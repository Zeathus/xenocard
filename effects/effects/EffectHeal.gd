extends Effect

class_name EffectHeal

var amount: int
var filter: CardFilter

func post_init():
	var params = param.split(",")
	amount = int(params[0])
	filter = CardFilter.new(params[1])

func effect(variables: Dictionary = {}):
	for c in parent.get_game_board().get_all_field_cards():
		if filter.is_valid(parent.host.owner, c, variables):
			c.heal(amount)
