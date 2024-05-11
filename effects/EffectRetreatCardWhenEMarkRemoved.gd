extends Effect

class_name EffectRetreatCardWhenEMarkRemoved

var filter: CardFilter

func post_init():
	filter = CardFilter.new(param)

func on_e_mark_removed():
	if filter.owner_only():
		if len(card.owner.field.get_standby_cards()) >= 4:
			return
		if len(card.owner.field.get_battlefield_cards()) == 0:
			return
	elif filter.enemy_only():
		if len(card.owner.get_enemy().field.get_standby_cards()) >= 4:
			return
		if len(card.owner.get_enemy().field.get_battlefield_cards()) == 0:
			return
	else:
		if len(card.owner.field.get_standby_cards()) >= 4 and \
			len(card.owner.get_enemy().field.get_standby_cards()) >= 4:
			return
		if len(card.owner.field.get_battlefield_cards()) == 0 and \
			len(card.owner.get_enemy().field.get_battlefield_cards()) == 0:
			return
	push_event(true)

func targets_to_select_for_effect() -> Array[CardFilter]:
	return [filter]

func handle_effect_targets(targets: Array[Card]):
	for t in targets:
		for i in range(4):
			if t.owner.field.get_card(Zone.STANDBY, i) == null:
				events.push_back(EventAutoMove.new(game_board, t.owner, t, Zone.STANDBY, i))
				break

func has_valid_targets() -> bool:
	for t in game_board.get_all_battlefield_cards():
		if filter.is_valid(card.owner, t):
			return true
	return false
