extends Effect

class_name EffectHealTarget

var filter: CardFilter
var amount: String

func post_init():
	var params = param.split(",")
	filter = CardFilter.new(params[0])
	amount = Formula.prepare(params[1], parent.host, parent.get_game_board())

func targets_to_select_for_effect() -> Array[CardFilter]:
	return [filter]

func effect(variables: Dictionary = {}):
	for t in variables["effect_targets"]:
		t.heal(Formula.calc(amount, parent.host, parent.get_game_board()))

func has_valid_targets(variables: Dictionary = {}) -> bool:
	for t in game_board.get_all_field_cards():
		if filter.is_valid(parent.host.owner, t, variables) and not t.downed:
			return true
	return false
