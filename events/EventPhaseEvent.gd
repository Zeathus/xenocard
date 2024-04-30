extends Event

class_name EventPhaseEvent

var player: Player
var phase_effects: Array

func _init(_game_board: GameBoard, _player: Player, _phase_effects: Array):
	super(_game_board)
	player = _player

func get_name() -> String:
	return "PhaseEvent"

func on_start():
	pass

func on_finish():
	game_board.end_phase()

func process(delta):
	if pass_to_child("process", [delta]):
		return
	if player.has_controller() and not player.controller.is_waiting():
		if player.controller.has_response():
			player.controller.receive()
		else:
			player.controller.request(
				[Controller.Action.EVENT, Controller.Action.END_PHASE],
				[Callable(), on_end_phase_pressed]
			)

func on_end_phase_pressed():
	if not has_children():
		finish()
