extends Effect

class_name EffectDown

var filter: CardFilter = null

func post_init():
	filter = CardFilter.new(param)

func effect(variables: Dictionary = {}):
	for c in parent.get_game_board().get_all_field_cards():
		if filter.is_valid(parent.host.owner, c, variables):
			c.down(parent.host)

func has_valid_targets(variables: Dictionary = {}) -> bool:
	for t in game_board.get_all_field_cards():
		if filter.is_valid(parent.host.owner, t, variables):
			return true
	return false

func get_effect_score(variables: Dictionary = {}) -> int:
	var score = 0
	for c in parent.get_game_board().get_all_field_cards():
		if filter.is_valid(parent.host.owner, c, variables):
			if c.get_attack_type() == Enum.AttackType.HAND:
				continue
			if parent.host.owner == c.owner:
				score -= c.get_atk()
			else:
				score += c.get_atk()
	return score
