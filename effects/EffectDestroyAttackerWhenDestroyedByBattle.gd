extends CardEffect

class_name EffectDestroyAttackerWhenDestroyedByBattle

var amount: int

func post_init():
	amount = int(param)

func on_destroyed(attacker: Card, source: Card.DamageSource):
	if source == Card.DamageSource.BATTLE:
		events.push_back(EventDestroy.new(get_game_board(), card, attacker, Card.DamageSource.EFFECT))
