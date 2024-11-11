extends Effect

class_name EffectSearch

var filter: CardFilter

func post_init():
	filter = CardFilter.new(param)

func effect(variables: Dictionary = {}):
	var search_event = EventSearch.new(game_board, parent.host.owner, filter, "Select a card to add to your hand")
	search_event.forced = true
	parent.events.push_back(search_event)
