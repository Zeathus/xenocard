extends Effect

class_name EffectGainATKForEachAlly

var amount: int = 0
var filter: CardFilter = null

func post_init():
	var params = param.split(",")
	amount = int(params[0])
	if len(params) >= 2:
		filter = CardFilter.new(params[1])

func get_atk(atk: int) -> int:
	if card.equipped_weapon:
		return atk
	for c in card.owner.field.get_battlefield_cards() + card.owner.field.get_standby_cards():
		if filter:
			if filter.is_valid(card.owner, c):
				atk += amount
		else:
			atk += amount
	if atk < 0:
		atk = 0
	return atk
