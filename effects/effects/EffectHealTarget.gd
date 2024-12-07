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
		if t.instance:
			t.instance.play_animation("Heal")

func has_valid_targets(variables: Dictionary = {}) -> bool:
	for t in game_board.get_all_field_cards():
		if filter.is_valid(parent.host.owner, t, variables) and not t.downed:
			return true
	return false

func get_effect_score(variables: Dictionary = {}) -> int:
	var best_score = -999
	for c in parent.get_game_board().get_all_field_cards():
		if filter.is_valid(parent.host.owner, c, variables):
			best_score = max(best_score, get_target_score(c))
	return best_score

func get_target_score(target: Card) -> int:
	var score = -1
	if target.hp > target.get_max_hp() / 2:
		return score
	var amt = Formula.calc(amount, parent.host, parent.get_game_board())
	if target.owner == parent.host.owner:
		score += min(amt, target.get_max_hp() - target.hp)
	else:
		score -= min(amt, target.get_max_hp() - target.hp)
	return score
