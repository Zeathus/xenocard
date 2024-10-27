extends Effect

class_name EffectGlobalModifyATK

var amount: int = 0
var filter: CardFilter

func post_init():
	var arg = param.split(",")
	amount = int(arg[0])
	if len(arg) > 1:
		filter = CardFilter.new(arg[1])

func is_active() -> bool:
	return super.is_active()

func is_global() -> bool:
	return true

func applies_to(target: Card) -> bool:
	if filter:
		return filter.is_valid(card.owner, target)
	return super.applies_to(target)

func apply_effect(target: Card) -> Effect:
	return EffectModifyATK.new(game_board, target, "%d" % amount).set_host(card)
