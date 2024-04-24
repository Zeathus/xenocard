extends CardEffect

class_name EffectDiscardAttributeToPlay

var requirements: Array[Card.Attribute]

func post_init():
	for i in param.split(","):
		requirements.push_back(Card.attribute_from_string(i))

func targets_to_select_for_set(list: Array[Callable]):
	for r in requirements:
		list.push_back(func valid(card: Card) -> bool:
			if card.owner != game_board.get_turn_player():
				return false
			if card.attribute != r:
				return false
			return true
		)

func can_replace_target() -> bool:
	return true

func handle_set_targets(targets: Array[Card]):
	for target in targets:
		events.push_back(EventDestroy.new(get_game_board(), card, target, Damage.new(Damage.EFFECT | Damage.DISCARD)))
