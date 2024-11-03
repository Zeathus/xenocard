extends Effect

class_name EffectEnemyDiscardTarget

var amount: int
var filter: CardFilter

func post_init():
	var arg = param.split(",")
	amount = int(arg[0])
	filter = CardFilter.new(arg[1])

func effect(variables: Dictionary = {}):
	for i in amount:
		parent.events.push_back(EventSelectDiscard.new(parent.get_game_board(), parent.host.owner.get_enemy(), filter, parent.host))

func has_valid_targets(variables: Dictionary = {}) -> bool:
	var count = 0
	for c in parent.host.owner.hand.cards:
		if filter.is_valid(parent.host.owner.get_enemy(), c):
			count += 1
	for c in parent.host.owner.get_enemy().hand.cards:
		if filter.is_valid(parent.host.owner.get_enemy(), c):
			count += 1
	for c in parent.get_game_board().get_all_field_cards():
		if filter.is_valid(parent.host.owner.get_enemy(), c):
			count += 1
	return count >= amount
