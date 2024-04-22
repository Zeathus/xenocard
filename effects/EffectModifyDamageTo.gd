extends CardEffect

class_name EffectModifyDamageTo

var amount: int = 0
var filter: CardFilter = null

func post_init():
	var params = param.split(",")
	amount = int(params[0])
	if len(params) >= 2:
		filter = CardFilter.new(params[1])

func get_atk(target, atk: int) -> int:
	if target == null or target.is_player():
		return atk
	if filter and not filter.is_valid(card.owner, target):
		return atk
	atk += amount
	if atk < 0:
		atk = 0
	return atk
