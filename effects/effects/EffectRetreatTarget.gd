extends Effect

class_name EffectRetreatTarget

var filter: CardFilter

func post_init():
	filter = CardFilter.new(param)

func targets_to_select_for_effect() -> Array[CardFilter]:
	return [filter]

func effect(variables: Dictionary = {}):
	for t in variables["effect_targets"]:
		for i in range(4):
			if t.owner.field.get_card(Enum.Zone.STANDBY, i) == null:
				parent.events.push_back(EventAutoMove.new(game_board, t.owner, t, Enum.Zone.STANDBY, i))
				break

func has_valid_targets(variables: Dictionary = {}) -> bool:
	for t in game_board.get_all_battlefield_cards():
		if filter.is_valid(parent.host.owner, t, variables):
			for i in range(4):
				if t.owner.field.get_card(Enum.Zone.STANDBY, i) == null:
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
		score += 5 - target.hp
	else:
		score += target.hp + target.get_atk()
	return score
