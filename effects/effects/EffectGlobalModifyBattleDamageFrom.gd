extends Effect

class_name EffectGlobalModifyBattleDamage

var amount: int = 0
var target_filter: CardFilter = null
var attacker_filter: String = ""

func post_init():
	var arg = param.split(",")
	amount = int(arg[0])
	if len(arg) > 1:
		target_filter = CardFilter.new(arg[1])
	if len(arg) > 2:
		attacker_filter = arg[2]

func is_active() -> bool:
	return super.is_active()

func is_global() -> bool:
	return true

func applies_to(target: Card) -> bool:
	if target_filter:
		return target_filter.is_valid(card.owner, target)
	return super.applies_to(target)

func apply_effect(target: Card) -> Effect:
	var params = "%d" % amount
	if attacker_filter != "":
		params += ",%s" % attacker_filter
	return EffectModifyBattleDamageFrom.new(game_board, target, params).set_host(card)
