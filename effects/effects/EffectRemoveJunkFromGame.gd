extends Effect

class_name EffectRemoveJunkFromGame

func effect(variables: Dictionary = {}):
	card.owner.junk.clear()
