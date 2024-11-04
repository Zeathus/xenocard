extends Effect

class_name EffectDamageTarget

var filter: CardFilter

func post_init():
	filter = CardFilter.new(param)

func targets_to_select_for_effect() -> Array[CardFilter]:
	return [filter]

func effect(variables: Dictionary = {}):
	for t in variables["effect_targets"]:
		parent.events.push_back(EventDestroy.new(parent.get_game_board(), parent.host, t, Damage.new(Damage.EFFECT | Damage.DESTROY)))

func has_valid_targets(variables: Dictionary = {}) -> bool:
	for t in game_board.get_all_field_cards():
		if filter.is_valid(parent.host.owner, t, variables):
			return true
	return false
