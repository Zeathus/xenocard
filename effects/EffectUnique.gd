extends CardEffect

class_name EffectUnique

func conflicts_with_card(card: Card) -> bool:
	if self.card.set_name == card.set_name and self.card.name == card.name and self.card.owner == card.owner:
		return true
	return super.conflicts_with_card(card)
