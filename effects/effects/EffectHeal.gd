extends Effect

class_name EffectHeal

var amount: int
var filter: CardFilter

func post_init():
	var params = param.split(",")
	amount = int(params[0])
	filter = CardFilter.new(params[1])

func effect(variables: Dictionary = {}):
	for c in parent.get_game_board().get_all_field_cards():
		if filter.is_valid(parent.host.owner, c, variables):
			c.heal(amount)
			if c.instance:
				c.instance.play_animation("Heal")

func get_effect_score(variables: Dictionary = {}) -> int:
	var score = -1
	for c in parent.get_game_board().get_all_field_cards():
		if filter.is_valid(parent.host.owner, c, variables):
			if c.hp > c.get_max_hp() / 2:
				continue
			if parent.host.owner == c.owner:
				score += min(amount, c.get_max_hp() - c.hp)
			else:
				score -= min(amount, c.get_max_hp() - c.hp)
	return score
