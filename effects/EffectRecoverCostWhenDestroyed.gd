extends Effect

class_name EffectRecoverCostWhenDestroyed

func on_destroyed(attacker: Card, source: Damage):
	if card.cost > 0:
		push_event()

func effect():
	var recovered = card.owner.recover(card.cost)
	for i in range(recovered):
		events.push_back(EventRecover.new(card.owner.game_board, card.owner))
