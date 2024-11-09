extends Effect

class_name EffectApplyEffectToPlayer

func effect(variables: Dictionary = {}):
	parent.host.owner.applied_effects.push_back(parent.applied_effect.instantiate(parent.host))
