extends Event

class_name EventPhaseAdjust

var player: Player
var phase_effects: Array

func _init(_game_board: GameBoard, _player: Player, _phase_effects: Array):
	super(_game_board)
	player = _player
	phase_effects = _phase_effects

func get_name() -> String:
	return "PhaseAdjust"

func on_start():
	for e in phase_effects:
		e.effect()
		for event in e.get_events():
			queue_event(event)
	phase_effects.clear()
	for card in player.field.get_all_cards():
		for e in card.get_effects():
			e.adjust()
			for event in e.get_events():
				queue_event(event)
		if card.downed and card.downed_turn != card.turn_count:
			card.undown()
	for card in player.get_enemy().field.get_all_cards():
		for e in card.get_effects():
			e.adjust_enemy()
			for event in e.get_events():
				queue_event(event)

func on_finish():
	game_board.end_phase()

func process(delta):
	if pass_to_child("process", [delta]):
		return
	finish()
