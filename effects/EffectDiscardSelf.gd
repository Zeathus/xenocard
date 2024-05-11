extends Effect

class_name EffectDiscardSelf

func effect():
	events.push_back(EventDestroy.new(game_board, card, card, Damage.new(Damage.EFFECT | Damage.DISCARD)))
