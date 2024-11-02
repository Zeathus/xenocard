extends Effect

class_name EffectEquipsTo

var filter: CardFilter

func post_init():
	filter = CardFilter.new(param)

func equips_to(holder: Card) -> bool:
	return holder.owner == parent.host.owner and filter.is_valid(parent.host.owner, holder)
