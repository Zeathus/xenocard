extends Effect

class_name EffectDiscardSelf

func effect(variables: Dictionary = {}):
	parent.events.push_back(EventDestroy.new(game_board, parent.host, parent.host, Damage.new(Damage.EFFECT | Damage.DISCARD)))
