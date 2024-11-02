extends Effect

class_name EffectDamageDeck

var amount: int

func post_init():
	amount = int(param)

func effect(variables: Dictionary = {}):
	parent.events.push_back(EventDamage.new(game_board, parent.host, parent.host.owner.get_enemy(), amount, Damage.new(Damage.EFFECT)))
