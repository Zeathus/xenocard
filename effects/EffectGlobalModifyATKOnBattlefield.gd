extends CardEffect

class_name EffectGlobalModifyATKOnBattlefield

var amount: int = 0
var filter: CardFilter

func post_init():
	var arg = param.split(",")
	amount = int(arg[0])
	if len(arg) > 1:
		filter = CardFilter.new(arg[1])

func is_active() -> bool:
	if card.zone != Card.Zone.BATTLEFIELD:
		return false
	return super.is_active()

func is_global() -> bool:
	return true

func applies_to(target: Card) -> bool:
	if filter:
		return filter.is_valid(card.owner, target)
	return super.applies_to(target)

func apply_effect(target: Card) -> CardEffect:
	return EffectModifyATK.new(game_board, target, param).set_host(card)
