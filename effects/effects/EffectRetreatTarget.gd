extends Effect

class_name EffectRetreatTarget

var filter: CardFilter

func post_init():
	filter = CardFilter.new(param)

func targets_to_select_for_effect() -> Array[CardFilter]:
	return [filter]

func effect(variables: Dictionary = {}):
	for t in variables["effect_targets"]:
		for i in range(4):
			if t.owner.field.get_card(Enum.Zone.STANDBY, i) == null:
				parent.events.push_back(EventAutoMove.new(game_board, t.owner, t, Enum.Zone.STANDBY, i))
				break

func has_valid_targets() -> bool:
	for t in game_board.get_all_battlefield_cards():
		if filter.is_valid(card.owner, t):
			for i in range(4):
				if t.owner.field.get_card(Enum.Zone.STANDBY, i) == null:
					return true
	return false
