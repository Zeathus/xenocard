extends Effect

class_name EffectPayCostEnemy

var amount: int

func post_init():
	amount = int(param)

func effect(variables: Dictionary = {}):
	var cost_paid: int = parent.host.owner.get_enemy().pay_cost(amount)
	for i in range(cost_paid):
		parent.events.push_back(EventPayCost.new(parent.host.owner.game_board, parent.host.owner.get_enemy()))

func get_effect_score(variables: Dictionary = {}) -> int:
	return amount
