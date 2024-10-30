extends Effect

class_name EffectSearch

var filter: CardFilter

func post_init():
	filter = CardFilter.new(param)

func effect(variables: Dictionary = {}):
	parent.events.push_back(EventSearch.new(game_board, parent.host.owner, filter, "Select a card to add to your hand"))
