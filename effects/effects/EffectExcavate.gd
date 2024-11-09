extends Effect

class_name EffectExcavate

var amount: String
var filter: CardFilter

func post_init():
	var params = param.split(",")
	amount = Formula.prepare(params[0], parent.host, game_board)
	filter = CardFilter.new(params[1])

func effect(variables: Dictionary = {}):
	parent.events.push_back(EventExcavate.new(game_board, parent.host.owner, Formula.calc(amount, parent.host, game_board), filter, "Select a card to add to your hand"))

func has_valid_targets(variables: Dictionary = {}):
	return parent.host.owner.deck.size() > 0
