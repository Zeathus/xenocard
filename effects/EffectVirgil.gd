extends Effect

class_name EffectVirgil

# On your enemy's adjust phase when this card is on the battlefield,
# all {Realians} on your battlefield are destroyed, and 4 damage is
# dealt to the enemy's deck for each.

func adjust_enemy():
	if card.zone != Zone.BATTLEFIELD:
		return
	for c in card.owner.field.get_battlefield_cards():
		if c.attribute == Attribute.REALIAN:
			push_event()
			break

func effect():
	for c in card.owner.field.get_battlefield_cards():
		if c.attribute == Attribute.REALIAN:
			events.push_back(EventDestroy.new(card.owner.game_board, card, c, Damage.new(Damage.EFFECT | Damage.DESTROY)))
			events.push_back(EventDamage.new(card.owner.game_board, card, card.owner.get_enemy(), 4, Damage.new(Damage.EFFECT)))
