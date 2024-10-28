extends Effect

class_name EffectApplyEffect

func effect():
	var effect = parent.applied_effect.instantiate(parent.host)
	target.applied_effects.push_back(effect)
