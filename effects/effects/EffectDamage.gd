extends Effect

class_name EffectDamage

var amount: int
var filter: CardFilter = null

func post_init():
	var params = param.split(",")
	amount = int(params[0])
	filter = CardFilter.new(params[1])

func effect(variables: Dictionary = {}):
	for c in parent.get_game_board().get_all_field_cards():
		if filter.is_valid(parent.host.owner, c, variables):
			parent.events.push_back(EventDamage.new(parent.get_game_board(), parent.host, c, amount, Damage.new(Damage.EFFECT)))