extends Effect

class_name EffectApplyEffect

var filter: CardFilter = null

func post_init():
	filter = CardFilter.new(param)

func effect(variables: Dictionary = {}):
	for c in parent.get_game_board().get_all_field_cards():
		if filter.is_valid(parent.host.owner, c, variables):
			var effect = parent.applied_effect.instantiate(parent.host)
			c.applied_effects.push_back(effect)
