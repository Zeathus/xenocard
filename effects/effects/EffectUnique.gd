extends Effect

class_name EffectUnique

func is_active() -> bool:
	return true

func conflicts_with_card(card: Card) -> bool:
	if self.card.get_set_name() == card.get_set_name() and \
		self.card.get_name() == card.get_name() and \
		self.card.owner == card.owner:
		return true
	return super.conflicts_with_card(card)
