extends Effect

class_name EffectReturnToHand

var filter: CardFilter = null

func post_init():
	filter = CardFilter.new(param)

func effect(variables: Dictionary = {}):
	for c in game_board.get_all_battlefield_cards():
		if filter.is_valid(parent.host.owner, c, variables):
			parent.events.push_back(EventFieldToHand.new(parent.get_game_board(), c))
