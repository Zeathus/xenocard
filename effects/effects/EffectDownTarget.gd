extends Effect

class_name EffectDownTarget

var filter: CardFilter

func post_init():
	filter = CardFilter.new(param)

func targets_to_select_for_effect() -> Array[CardFilter]:
	return [filter]

func effect(variables: Dictionary = {}):
	for t in variables["effect_targets"]:
		t.down(parent.host)

func has_valid_targets(variables: Dictionary = {}) -> bool:
	for t in game_board.get_all_field_cards():
		if filter.is_valid(parent.host.owner, t, variables) and not t.downed:
			return true
	return false
