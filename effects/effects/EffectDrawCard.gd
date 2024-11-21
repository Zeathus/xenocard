extends Effect

class_name EffectDrawCard

func has_valid_targets(variables: Dictionary = {}) -> bool:
	return parent.host.owner.can_draw()

func effect(variables: Dictionary = {}):
	parent.events.push_back(EventDrawCard.new(parent.host.owner.game_board, parent.host.owner))

func get_effect_score(variables: Dictionary = {}) -> int:
	return 2
