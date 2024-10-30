extends Effect

class_name EffectUnique

func conflicts_with_card(card: Card) -> bool:
	if parent.host.get_name() == card.get_name() and \
		parent.host.owner == card.owner:
		return true
	return super.conflicts_with_card(card)
