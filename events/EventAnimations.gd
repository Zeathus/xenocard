extends Event

class_name EventAnimations

var animations: Array[GameAnimation]

func _init(_game_board: GameBoard, _animations: Array[GameAnimation]):
	broadcasted = false
	super(_game_board)
	animations = _animations

func get_name() -> String:
	return "Animations"

func process(delta):
	for a in animations:
		a.update(delta)

func is_done():
	for a in animations:
		if not a.is_done():
			return false
	return true
