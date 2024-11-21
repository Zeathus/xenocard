extends Effect

class_name EffectReturnToHand

var filter: CardFilter = null

func post_init():
	filter = CardFilter.new(param)

func effect(variables: Dictionary = {}):
	for c in game_board.get_all_battlefield_cards():
		if filter.is_valid(parent.host.owner, c, variables):
			parent.events.push_back(EventFieldToHand.new(parent.get_game_board(), c))

func get_effect_score(variables: Dictionary = {}) -> int:
	var best_score = -999
	for c in parent.get_game_board().get_all_field_cards():
		if filter.is_valid(parent.host.owner, c, variables):
			best_score = max(best_score, get_target_score(c))
	return best_score

func get_target_score(target: Card) -> int:
	var score = 0
	if target.get_type() == Enum.Type.BATTLE:
		if target.owner == parent.host.owner:
			score -= target.hp + target.get_atk()
		else:
			score += target.hp + target.get_atk()
	else:
		score += -2 if target.owner == parent.host.owner else 2
	return score
