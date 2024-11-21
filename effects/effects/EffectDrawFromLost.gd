extends Effect

class_name EffectDrawFromLost

var amount: int

func post_init():
	amount = int(param)

func effect(variables: Dictionary = {}):
	for i in range(amount):
		parent.events.push_back(EventDrawCardFromLost.new(parent.get_game_board(), parent.host.owner))

func has_valid_targets(variables: Dictionary = {}) -> bool:
	return parent.host.owner.lost.size() >= amount

func get_effect_score(variables: Dictionary = {}) -> int:
	return 4 if parent.host.owner.lost.size() >= amount else 0
