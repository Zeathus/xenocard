extends Effect

class_name EffectNoWeapons

func is_active() -> bool:
	return true

func can_equip_weapon(weapon: Card) -> bool:
	return false
