extends Effect

class_name EffectSearchJunk

var filter: CardFilter

func post_init():
	filter = CardFilter.new(param)

func effect(variables: Dictionary = {}):
	var search_event = EventSearchJunk.new(game_board, parent.host.owner, filter, "Select a card to add to your hand")
	search_event.forced = true
	parent.events.push_back(search_event)

func has_valid_targets(variables: Dictionary = {}):
	for c in parent.host.owner.junk.cards:
		if filter.is_valid(parent.host.owner, c, variables):
			return true
	return false

func get_effect_score(variables: Dictionary = {}) -> int:
	for c in parent.host.owner.junk.cards:
		if filter.is_valid(parent.host.owner, c, variables):
			return 4
	return 0
