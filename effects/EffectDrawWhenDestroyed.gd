extends CardEffect

class_name EffectDrawWhenDestroyed

func on_destroyed(attacker: Card, source: Damage):
	if card.owner.can_draw():
		push_event()

func effect():
	events.push_back(EventDrawCard.new(card.owner.game_board, card.owner))
