extends Event

class_name EventAnimation

var animation: GameAnimation

func _init(_game_board: GameBoard, _animation: GameAnimation):
	broadcasted = false
	super(_game_board)
	animation = _animation

func get_name() -> String:
	return "Animation"

func process(delta):
	animation.update(delta)

func is_done():
	return animation.is_done()
