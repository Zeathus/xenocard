extends Effect

class_name EffectDestroyAttackerWhenDestroyedByAttack

var amount: int
var attacker: Card

func post_init():
	amount = int(param)

func on_destroyed(attacker: Card, source: Damage):
	if source.normal_attack() and not attacker.is_destroyed():
		self.attacker = attacker
		push_event()

func effect():
	events.push_back(EventDestroy.new(get_game_board(), card, attacker, Damage.new(Damage.EFFECT | Damage.DESTROY)))
