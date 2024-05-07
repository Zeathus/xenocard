extends CardEffect

class_name EffectDamageDeckWhenDestroyedByAttack

var amount: int

func post_init():
	amount = int(param)

func on_destroyed(attacker: Card, source: Damage):
	if source.normal_attack():
		push_event()

func effect():
	events.push_back(EventDamage.new(game_board, card, card.owner.get_enemy(), amount, Damage.new(Damage.EFFECT)))
