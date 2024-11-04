extends Effect

class_name EffectDestroyTarget

var amount: int
var filter: CardFilter = null

func post_init():
	var params = param.split(",")
	amount = int(params[0])
	filter = CardFilter.new(params[1])

func targets_to_select_for_effect() -> Array[CardFilter]:
	return [filter]

func effect(variables: Dictionary = {}):
	for t in variables["effect_targets"]:
		parent.events.push_back(EventDamage.new(parent.get_game_board(), parent.host, t, amount, Damage.new(Damage.EFFECT)))

func has_valid_targets(variables: Dictionary = {}) -> bool:
	for t in game_board.get_all_field_cards():
		if filter.is_valid(parent.host.owner, t, variables):
			return true
	return false
