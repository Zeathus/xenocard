extends Event

class_name EventPhaseAdjust

var player: Player
var phase_effects: Array
var state: int = 0

func _init(_game_board: GameBoard, _player: Player, _phase_effects: Array):
	super(_game_board)
	player = _player
	phase_effects = _phase_effects

func get_name() -> String:
	return "PhaseAdjust"

func on_start():
	for e in phase_effects:
		e.effect()
		for event in e.parent.get_events():
			queue_event(event)
	phase_effects.clear()
	for card in player.field.get_all_cards():
		card.trigger_effects(Enum.Trigger.ADJUST_PHASE, self)
		card.trigger_effects(Enum.Trigger.ADJUST_PHASE_PLAYER, self)
	for card in player.get_enemy().field.get_all_cards():
		card.trigger_effects(Enum.Trigger.ADJUST_PHASE, self)
		card.trigger_effects(Enum.Trigger.ADJUST_PHASE_ENEMY, self)

func on_finish():
	game_board.end_phase()

func process(delta):
	if pass_to_child("process", [delta]):
		return
	match state:
		0: 
			# Update duration of card effects
			for card in game_board.get_all_field_cards():
				var to_erase = []
				# Self-owned durations
				for e in card.effects:
					if e.duration == -1:
						continue
					e.duration -= 1
					if e.duration == 0:
						card.instance.set_duration(e.duration)
						for on_end in e.effects_on_end:
							on_end.effect({"self": card})
							for event in e.events:
								queue_event(event)
							e.events.clear()
							if e.duration != 0:
								break
						if e.duration == 0:
							to_erase.push_back(e)
					card.instance.set_duration(e.duration)
				for e in to_erase:
					card.effects.erase(e)
				to_erase.clear()
				# Applied durations
				for e in card.applied_effects:
					if e.duration == -1:
						continue
					e.duration -= 1
					if e.duration == 0:
						for on_end in e.effects_on_end:
							on_end.effect({"self": card})
							for event in e.events:
								queue_event(event)
							e.events.clear()
							if e.duration != 0:
								break
						if e.duration == 0:
							to_erase.push_back(e)
				for e in to_erase:
					card.applied_effects.erase(e)
				to_erase.clear()
				# Player applied effects
				for p: Player in [player, player.get_enemy()]:
					for e in p.applied_effects:
						if e.duration == -1:
							continue
						e.duration -= 1
						if e.duration == 0:
							for on_end in e.effects_on_end:
								on_end.effect()
								for event in e.events:
									queue_event(event)
								e.events.clear()
								if e.duration != 0:
									break
							if e.duration == 0:
								to_erase.push_back(e)
					for e in to_erase:
						p.applied_effects.erase(e)
					to_erase.clear()
		1:
			for card in player.field.get_all_cards():
				if card.downed and card.downed_turn != card.turn_count:
					card.undown()
		2:
			finish()
	state += 1
