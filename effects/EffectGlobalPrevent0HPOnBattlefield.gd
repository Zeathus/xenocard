extends Effect

class_name EffectGlobalPrevent0HPOnBattlefield

var filter: CardFilter

func post_init():
	if len(param) > 0:
		filter = CardFilter.new(param)

func is_active() -> bool:
	if card.zone != Zone.BATTLEFIELD:
		return false
	return super.is_active()

func is_global() -> bool:
	return true

func applies_to(target: Card) -> bool:
	if filter:
		return filter.is_valid(card.owner, target)
	return super.applies_to(target)

func apply_effect(target: Card) -> Effect:
	return EffectPrevent0HP.new(game_board, target, param).set_host(card)
