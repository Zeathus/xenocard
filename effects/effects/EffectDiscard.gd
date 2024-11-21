extends Effect

class_name EffectDiscard

var filter: CardFilter

func post_init():
	filter = CardFilter.new(param)

func effect(variables: Dictionary = {}):
	for c in parent.host.owner.hand.cards:
		if filter.is_valid(parent.host.owner, c, variables):
			parent.events.push_back(EventDestroy.new(parent.get_game_board(), parent.host, c, Damage.new(Damage.EFFECT | Damage.DISCARD)))
	for c in parent.host.owner.field.get_all_cards():
		if filter.is_valid(parent.host.owner, c, variables):
			parent.events.push_back(EventDestroy.new(parent.get_game_board(), parent.host, c, Damage.new(Damage.EFFECT | Damage.DISCARD)))

func has_valid_targets(variables: Dictionary = {}) -> bool:
	var count = 0
	for c in parent.host.owner.hand.cards:
		if filter.is_valid(parent.host.owner, c, variables):
			count += 1
	for c in parent.host.owner.field.get_all_cards():
		if filter.is_valid(parent.host.owner, c, variables):
			count += 1
	return count > 0

func get_effect_score(variables: Dictionary = {}) -> int:
	var score = 0
	for c in parent.get_game_board().get_all_field_cards():
		if filter.is_valid(parent.host.owner, c, variables):
			if parent.host.owner == c.owner:
				score -= 1
			else:
				score += 2
	return score
