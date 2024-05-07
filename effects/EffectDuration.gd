extends CardEffect

class_name EffectDuration

var adjust_phases: int

func post_init():
	adjust_phases = int(param)

func on_set():
	duration = adjust_phases
	card.instance.set_duration(duration)

func adjust():
	duration -= 1
	card.instance.set_duration(duration)
	if duration <= 0:
		events.push_back(EventDestroy.new(game_board, card, card, Damage.new(Damage.DISCARD | Damage.EFFECT)))

func adjust_enemy():
	adjust()
