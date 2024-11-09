extends Effect

class_name EffectDestroy

var filter: CardFilter = null

func post_init():
	filter = CardFilter.new(param)

func effect(variables: Dictionary = {}):
	for c in parent.get_game_board().get_all_field_cards():
		if filter.is_valid(parent.host.owner, c, variables):
			parent.events.push_back(EventDestroy.new(parent.get_game_board(), parent.host, c, Damage.new(Damage.EFFECT | Damage.DESTROY)))
	
func has_valid_targets(variables: Dictionary = {}) -> bool:
	for t in game_board.get_all_field_cards():
		if filter.is_valid(parent.host.owner, t, variables):
			return true
	return false
