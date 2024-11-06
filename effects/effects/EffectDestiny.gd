extends Effect

class_name EffectDestiny

# Discard one {Human} battle card on your battlefield to play one
# {Human} battle card from your junk pile in its place. Character
# cards and <unique> cards cannot be retrieved from the junk pile.
# Damage taken carries over, and any equipped {weapon} is destroyed.

var card_zone_index: int
var card_hp: int
var field_filter: CardFilter = CardFilter.new("owner=self;attribute=human;zone=battlefield")
var junk_filter: CardFilter = CardFilter.new("attribute=human;unique=false")
var search_event: Event

func targets_to_select_for_effect() -> Array[CardFilter]:
	return [field_filter]

func effect(variables: Dictionary = {}):
	for t in variables["effect_targets"]:
		card_hp = t.hp
		card_zone_index = t.zone_index
	search_event = EventSearchJunk.new(game_board, parent.host.owner, junk_filter, "Select a card to set to the battlefield", handle_junk_target)
	search_event.forced = true
	parent.events.push_back(search_event)

func has_valid_targets(variables: Dictionary = {}) -> bool:
	var valid = false
	for card in parent.host.owner.junk.cards:
		if junk_filter.is_valid(parent.host.owner, card, variables):
			valid = true
	if valid:
		for card in parent.host.owner.field.get_battlefield_cards():
			if field_filter.is_valid(parent.host.owner, card, variables):
				return true
	return false

func handle_junk_target(index: int, card: Card):
	card.modify_for_set.push_back(func(x):
		x.set_hp(card_hp)
	)
	var set_event = EventAutoSet.new(game_board, card.owner, card, Enum.Zone.BATTLEFIELD, card_zone_index)
	search_event.queue_event(set_event)
