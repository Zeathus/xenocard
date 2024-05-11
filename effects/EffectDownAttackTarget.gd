extends Effect

class_name EffectDownAttackTarget

func on_target_attacked(target: Card):
	target.down(card)
