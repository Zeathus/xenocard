extends Effect

class_name EffectSearch

var filter: CardFilter

func post_init():
	filter = CardFilter.new(param)

func effect(variables: Dictionary = {}):
	var search_event = EventSearch.new(game_board, parent.host.owner, filter, "Select a card to add to your hand")
	parent.events.push_back(search_event)

func get_effect_score(variables: Dictionary = {}) -> int:
	for c in parent.host.owner.deck.cards:
		if filter.is_valid(parent.host.owner, c, variables):
			return 4
	return 0
