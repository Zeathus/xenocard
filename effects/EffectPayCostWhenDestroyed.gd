extends CardEffect

class_name EffectPayCostWhenDestroyed

var amount: int

func post_init():
	amount = int(param)

func on_destroyed(attacker: Card, source: Damage):
	var cost_paid: int = card.owner.pay_cost(amount)
	for i in range(cost_paid):
		events.push_back(EventPayCost.new(card.owner.game_board, card.owner))
