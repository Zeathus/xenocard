extends Event

class_name EventHint

# This event makes the game show hint text on the screen until the provided event is done.

var event: Event
var hint: String
var pos: HintNode.Position

func _init(_game_board: GameBoard, _event: Event, _hint: String, _pos: HintNode.Position):
	broadcasted = false
	super(_game_board)
	event = _event
	hint = _hint
	pos = _pos

func get_name() -> String:
	return "Hint"

func on_start():
	if "player" in event and not event.player.has_controller():
		game_board.get_hint_node().set_hint(hint)
		game_board.get_hint_node().set_pos(pos)
		game_board.get_hint_node().fade_in()
	queue_event(event)

func on_finish():
	game_board.get_hint_node().fade_out()

func process(delta):
	if pass_to_child("process", [delta]):
		return
	finish()

func on_end_phase_pressed():
	pass_to_child("on_end_phase_pressed")
