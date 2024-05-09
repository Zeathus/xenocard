extends CardEffect

class_name EffectDiscardFromHand

var amount: int
var filter: CardFilter = CardFilter.new("owner=self;zone=hand")

func post_init():
	amount = int(param)

func effect():
	for i in amount:
		events.push_back(EventSelectDiscard.new(game_board, card.owner, filter))

func has_valid_targets() -> bool:
	return card.owner.hand.size() >= amount
