extends CardEffect

class_name EffectDestroyAttackerWhenDestroyedByAttack

var amount: int

func post_init():
	amount = int(param)

func on_destroyed(attacker: Card, source: Damage):
	if source.normal_attack():
		events.push_back(EventDestroy.new(get_game_board(), card, attacker, Damage.new(Damage.EFFECT | Damage.DESTROY)))
