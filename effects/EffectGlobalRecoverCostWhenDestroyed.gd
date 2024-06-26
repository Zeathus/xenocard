extends CardEffect

class_name EffectGlobalRecoverCostWhenDestroyed

var filter: CardFilter

func post_init():
	if param != "":
		filter = CardFilter.new(param)

func is_active() -> bool:
	return super.is_active()

func is_global() -> bool:
	return true

func applies_to(target: Card) -> bool:
	if filter:
		return filter.is_valid(card.owner, target)
	return super.applies_to(target)

func apply_effect(target: Card) -> CardEffect:
	return EffectRecoverCostWhenDestroyed.new(game_board, target).set_host(card)
