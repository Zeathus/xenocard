extends CardEffect

class_name EffectMatthews

# When this card is on the field, both players pay one cost before their
# draw phase. When this card is on the battlefield, pay two cost instead.

func on_turn_start():
	turn_start(card.owner)

func on_turn_start_enemy():
	turn_start(card.owner.get_enemy())

func turn_start(player: Player):
	var cost_to_pay = 2 if card.zone == Card.Zone.BATTLEFIELD else 1
	var cost_paid = player.pay_cost(cost_to_pay)
	for i in range(cost_paid):
		events.push_back(EventPayCost.new(card.owner.game_board, player))
