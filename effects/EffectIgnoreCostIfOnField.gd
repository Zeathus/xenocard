extends CardEffect

class_name EffectIgnoreCostIfOnField

var filter: CardFilter

func post_init():
	filter = CardFilter.new(param)

func is_active() -> bool:
	return card.zone == Enum.Zone.HAND

func get_cost(cost: int) -> int:
	for c in card.owner.field.get_all_cards():
		if filter.is_valid(card.owner, c):
			return 0
	return super.get_cost(cost)
