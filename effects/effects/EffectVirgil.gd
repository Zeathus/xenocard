extends Effect

class_name EffectVirgil

# On your enemy's adjust phase when this card is on the battlefield,
# all {Realians} on your battlefield are destroyed, and 4 damage is
# dealt to the enemy's deck for each.

func effect(variables: Dictionary = {}):
	for c in parent.host.owner.field.get_battlefield_cards():
		if c.get_attribute() == Enum.Attribute.REALIAN:
			parent.events.push_back(EventDestroy.new(parent.get_game_board(), parent.host, c, Damage.new(Damage.EFFECT | Damage.DISCARD)))
			parent.events.push_back(EventDamage.new(parent.get_game_board(), parent.host, parent.host.owner.get_enemy(), 4, Damage.new(Damage.EFFECT)))

func has_valid_targets(variables: Dictionary = {}) -> bool:
	for c in parent.host.owner.field.get_battlefield_cards():
		if c.get_attribute() == Enum.Attribute.REALIAN:
			return true
	return false
