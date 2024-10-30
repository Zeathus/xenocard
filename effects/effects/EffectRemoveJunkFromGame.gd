extends Effect

class_name EffectRemoveJunkFromGame

func effect(variables: Dictionary = {}):
	parent.host.owner.junk.clear()
