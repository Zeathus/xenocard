extends CardEffect

class_name EffectSearch

var filter: CardFilter

func post_init():
	filter = CardFilter.new(param)

func effect():
	events.push_back(EventSearch.new(game_board, card.owner, filter, "Select a card to add to your hand"))
