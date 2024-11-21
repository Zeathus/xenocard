extends Effect

class_name EffectDiscardTarget

var amount: int
var filter: CardFilter

func post_init():
	var arg = param.split(",")
	amount = int(arg[0])
	filter = CardFilter.new(arg[1])

func effect(variables: Dictionary = {}):
	for i in amount:
		parent.events.push_back(EventSelectDiscard.new(parent.get_game_board(), parent.host.owner, filter, parent.host))

func has_valid_targets(variables: Dictionary = {}) -> bool:
	var count = 0
	for c in parent.host.owner.hand.cards:
		if filter.is_valid(parent.host.owner, c):
			count += 1
	for c in parent.host.owner.get_enemy().hand.cards:
		if filter.is_valid(parent.host.owner, c):
			count += 1
	for c in parent.get_game_board().get_all_field_cards():
		if filter.is_valid(parent.host.owner, c):
			count += 1
	return count >= amount

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
		score += -1 if target.owner == parent.host.owner else 2
	return score
