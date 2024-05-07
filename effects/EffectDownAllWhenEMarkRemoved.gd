extends CardEffect

class_name EffectDownAllWhenEMarkRemoved

func on_e_mark_removed():
	push_event()

func effect():
	for c in card.owner.field.get_all_cards():
		c.down(card)
	for c in card.owner.get_enemy().field.get_all_cards():
		c.down(card)
