extends Effect

class_name EffectEnemyDrawCard

func has_valid_targets(variables: Dictionary = {}) -> bool:
	return parent.host.owner.get_enemy().can_draw()

func effect(variables: Dictionary = {}):
	parent.events.push_back(EventDrawCard.new(parent.host.owner.game_board, parent.host.owner.get_enemy()))
