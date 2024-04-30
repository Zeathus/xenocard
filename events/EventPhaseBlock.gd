extends Event

class_name EventPhaseBlock

var player: Player
var phase_effects: Array
var ready_to_finish: bool = false

func _init(_game_board: GameBoard, _player: Player, _phase_effects: Array):
	super(_game_board)
	player = _player

func get_name() -> String:
	return "PhaseBlock"

func on_start():
	pass

func on_finish():
	game_board.end_phase()

func process(delta):
	if pass_to_child("process", [delta]):
		return
	if ready_to_finish:
		finish()
		return
	if player.has_controller() and not player.controller.is_waiting():
		if player.controller.has_response():
			player.controller.receive()
		else:
			player.controller.request(
				[Controller.Action.BLOCK, Controller.Action.END_PHASE],
				[Callable(), func(): ready_to_finish = true]
			)

func on_end_phase_pressed():
	if not has_children():
		finish()
