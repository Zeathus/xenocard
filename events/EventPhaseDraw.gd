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
	if player.can_draw():
		queue_event(EventDrawCard.new(game_board, player))

func on_finish():
	game_board.end_phase()

func process(delta):
	if pass_to_child("process", [delta]):
		return
	finish()
