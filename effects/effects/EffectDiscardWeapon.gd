extends Effect

class_name EffectDiscardWeapon

var filter: CardFilter = null

func post_init():
	filter = CardFilter.new(param)

func effect(variables: Dictionary = {}):
	for c in parent.get_game_board().get_all_field_cards():
		if filter.is_valid(parent.host.owner, c, variables):
			parent.events.push_back(EventDestroy.new(parent.get_game_board(), parent.host, c.equipped_weapon, Damage.new(Damage.EFFECT | Damage.DISCARD)))
			c.unequip()

func get_effect_score(variables: Dictionary = {}) -> int:
	var score = 0
	for c in parent.get_game_board().get_all_field_cards():
		if filter.is_valid(parent.host.owner, c, variables):
			if parent.host.owner == c.owner:
				score -= 1
			else:
				score += 2
	return score
