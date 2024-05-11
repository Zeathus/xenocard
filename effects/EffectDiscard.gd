extends Effect

class_name EffectDiscard

var amount: int
var filter: CardFilter

func post_init():
	var arg = param.split(",")
	amount = int(arg[0])
	filter = CardFilter.new(arg[1])

func effect():
	for i in amount:
		events.push_back(EventSelectDiscard.new(game_board, card.owner, filter))

func has_valid_targets() -> bool:
	var count = 0
	for c in card.owner.hand.cards:
		if filter.is_valid(card.owner, c):
			count += 1
	for c in card.owner.field.get_all_cards():
		if filter.is_valid(card.owner, c):
			count += 1
	return count >= amount
