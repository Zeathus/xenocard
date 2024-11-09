extends Effect

class_name EffectSearchJunk

var filter: CardFilter

func post_init():
	filter = CardFilter.new(param)

func effect(variables: Dictionary = {}):
	parent.events.push_back(EventSearchJunk.new(game_board, parent.host.owner, filter, "Select a card to add to your hand"))

func has_valid_targets(variables: Dictionary = {}):
	for c in parent.host.owner.junk.cards:
		if filter.is_valid(parent.host.owner, c, variables):
			return true
	return false
