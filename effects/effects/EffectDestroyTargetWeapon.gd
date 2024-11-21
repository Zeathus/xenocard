extends Effect

class_name EffectDestroyTargetWeapon

var filter: CardFilter

func post_init():
	filter = CardFilter.new(param)

func targets_to_select_for_effect() -> Array[CardFilter]:
	return [filter]

func effect(variables: Dictionary = {}):
	for t in variables["effect_targets"]:
		parent.events.push_back(EventDestroy.new(parent.get_game_board(), parent.host, t.equipped_weapon, Damage.new(Damage.EFFECT | Damage.DESTROY)))

func has_valid_targets(variables: Dictionary = {}) -> bool:
	for t in game_board.get_all_field_cards():
		if filter.is_valid(parent.host.owner, t, variables) and t.equipped_weapon:
			return true
	return false

func get_effect_score(variables: Dictionary = {}) -> int:
	var best_score = -999
	for c in parent.get_game_board().get_all_field_cards():
		if filter.is_valid(parent.host.owner, c, variables):
			best_score = max(best_score, get_target_score(c))
	return best_score

func get_target_score(target: Card) -> int:
	var score = 0
	if target.owner == parent.host.owner:
		score -= target.get_atk()
	else:
		score += target.get_atk()
	return score
