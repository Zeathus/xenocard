extends Event

class_name EventFlipCoin

var heads: bool
var coin_node: Coin
var state: int = 0
var time: float = 0.0

func _init(_game_board: GameBoard, _heads: bool):
	heads = _heads
	coin_node = _game_board.find_child("Coin", false)
	super(_game_board)

func get_name() -> String:
	return "FlipCoin"

func on_start():
	coin_node.visible = true

func on_finish():
	coin_node.visible = false

func process(delta):
	if pass_to_child("process", [delta]):
		return
	time += delta
	match state:
		0:
			if time > 1:
				game_board.play_se("coin_flip")
				if heads:
					coin_node.flip_heads()
				else:
					coin_node.flip_tails()
				state = 1
		1:
			if not coin_node.animating():
				state = 2
				time = 0.0
		2:
			if time > 2:
				finish()
