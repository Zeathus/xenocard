extends Effect

class_name EffectDiscardAttributeToPlay

var requirements: Array[Enum.Attribute]

func post_init():
	for i in param.split(","):
		requirements.push_back(Enum.attribute_from_string(i))

func skips_e_mark() -> bool:
	return true

func targets_to_select_for_set(list: Array[Callable]):
	for r in requirements:
		list.push_back(func valid(card: Card) -> bool:
			if card.owner != game_board.get_turn_player():
				return false
			if card.get_attribute() != r:
				return false
			if card.e_mark:
				return false
			return true
		)

func can_replace_target() -> bool:
	return true

func handle_set_targets(targets: Array[Card]):
	for target in targets:
		parent.events.push_back(EventDestroy.new(parent.get_game_board(), parent.host, target, Damage.new(Damage.EFFECT | Damage.DISCARD)))
