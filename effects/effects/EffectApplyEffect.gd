extends Effect

class_name EffectApplyEffect

var filter: CardFilter = null

func post_init():
	filter = CardFilter.new(param)

func effect(variables: Dictionary = {}):
	for c in parent.get_game_board().get_all_field_cards():
		if filter.is_valid(parent.host.owner, c, variables):
			var effect = parent.applied_effect.instantiate(parent.host)
			effect.set_target(c)
			c.applied_effects.push_back(effect)

func get_effect_score(variables: Dictionary = {}) -> int:
	var score = 0
	for c in parent.get_game_board().get_all_field_cards():
		if filter.is_valid(parent.host.owner, c, variables):
			if parent.host.owner == c.owner:
				score += 1
			else:
				score -= 1
	return score
