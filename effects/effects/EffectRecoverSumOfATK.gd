extends Effect

class_name EffectRecoverSumOfATK

var filter: CardFilter

func post_init():
	filter = CardFilter.new(param)

func effect(variables: Dictionary = {}):
	var recovered = 0
	for c in game_board.get_all_field_cards():
		if filter.is_valid(parent.host.owner, c, {"self": parent.host}):
			recovered += c.get_atk()
	parent.events.push_back(EventRecover.new(target.owner.game_board, target.owner, recovered))

func has_valid_targets(variables: Dictionary = {}) -> bool:
	return parent.host.owner.lost.size() > 0
