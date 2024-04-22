extends Event

class_name EventBlank

func _init(_game_board: GameBoard):
	super(_game_board)

func get_name() -> String:
	return "Blank"

func on_start():
	pass

func on_finish():
	pass

func process(delta):
	if pass_to_child("process", [delta]):
		return
	finish()
