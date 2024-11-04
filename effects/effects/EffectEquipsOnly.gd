extends Effect

class_name EffectEquipsOnly

var filter: CardFilter

func post_init():
	filter = CardFilter.new(param)

func can_equip_weapon(weapon: Card) -> bool:
	return filter.is_valid(target.owner, weapon)
