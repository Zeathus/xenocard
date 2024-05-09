extends CardEffect

class_name EffectDurationWithKeeper

var adjust_phases: int
var keeper_filter: CardFilter

func post_init():
	var arg = param.split(",")
	adjust_phases = int(arg[0])
	keeper_filter = CardFilter.new(arg[1])

func on_set():
	duration = adjust_phases
	card.instance.set_duration(duration)

func adjust():
	if duration > 0:
		duration -= 1
		card.instance.set_duration(duration)
	for c in game_board.get_all_field_cards():
		if keeper_filter.is_valid(card.owner, c):
			return
	if duration <= 0:
		events.push_back(EventDestroy.new(game_board, card, card, Damage.new(Damage.DISCARD | Damage.EFFECT)))

func adjust_enemy():
	adjust()
