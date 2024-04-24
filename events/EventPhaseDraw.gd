extends Event

class_name EventPhaseDraw

var player: Player
var phase_effects: Array

func _init(_game_board: GameBoard, _player: Player, _phase_effects: Array):
	super(_game_board)
	player = _player

func get_name() -> String:
	return "PhaseDraw"

func on_start():
	for c in player.field.get_all_cards():
		c.on_turn_start()
		for e in c.get_effects():
			e.on_turn_start()
			for event in e.get_events():
				queue_event(event)
	for c in player.get_enemy().field.get_all_cards():
		for e in c.get_effects():
			e.on_turn_start_enemy()
			for event in e.get_events():
				queue_event(event)

	var can_normal_draw = true
	for c in player.field.get_all_cards():
		for e in c.get_effects():
			if e.stops_normal_draw():
				can_normal_draw = false
	if can_normal_draw and player.can_draw():
		queue_event(EventDrawCard.new(game_board, player))

	for c in player.field.get_all_cards():
		for e in c.get_effects():
			e.after_normal_draw()
			for event in e.get_events():
				queue_event(event)

func on_finish():
	game_board.end_phase()

func process(delta):
	if pass_to_child("process", [delta]):
		return
	finish()
