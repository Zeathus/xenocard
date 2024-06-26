extends CardEffect

class_name EffectEquipsTo

var filter: CardFilter

func post_init():
	filter = CardFilter.new(param)

func is_active() -> bool:
	return true

func equips_to(holder: Card) -> bool:
	return holder.owner == card.owner and filter.is_valid(card.owner, holder)
