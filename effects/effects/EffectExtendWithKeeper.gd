extends Effect

class_name EffectExtendWithKeeper

var keeper_filter: CardFilter

func post_init():
	keeper_filter = CardFilter.new(param)

func effect(variables: Dictionary = {}):
	for card in parent.get_game_board().get_all_field_cards():
		if keeper_filter.is_valid(parent.host.owner, card, variables):
			parent.duration += 1
			break
