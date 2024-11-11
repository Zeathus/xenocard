extends Effect

class_name EffectApplyEffectToTarget

var filter: CardFilter = null

func post_init():
	filter = CardFilter.new(param)

func targets_to_select_for_effect() -> Array[CardFilter]:
	return [filter]

func effect(variables: Dictionary = {}):
	for t in variables["effect_targets"]:
		var effect = parent.applied_effect.instantiate(parent.host)
		effect.set_target(t)
		t.applied_effects.push_back(effect)

func has_valid_targets(variables: Dictionary = {}) -> bool:
	for t in game_board.get_all_field_cards():
		if filter.is_valid(parent.host.owner, t, variables):
			return true
	return false
