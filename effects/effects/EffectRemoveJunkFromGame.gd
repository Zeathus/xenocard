extends Effect

class_name EffectRemoveJunkFromGame

func effect():
	card.owner.junk.clear()
