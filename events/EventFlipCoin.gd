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
	broadcast()
	coin_node.position.y = 700

func on_finish():
	coin_node.visible = false

func process(delta):
	if pass_to_child("process", [delta]):
		return
	time += delta
	match state:
		0:
			if time > 1:
				coin_node.visible = true
				game_board.play_se("coin_flip")
				game_board.play_animation("coin_flip")
				if heads:
					coin_node.flip_heads()
				else:
					coin_node.flip_tails()
				state = 1
		1:
			if not coin_node.animating():
				coin_node.show_result()
				state = 2
		2:
			if not coin_node.animating():
				finish()

func broadcast():
	if game_board.is_server():
		for p: Player in [game_board.get_turn_player(), game_board.get_turn_enemy()]:
			var args: Array = [1 if p == game_board.get_turn_player() else 0]
			p.controller.broadcast_event(get_name(), args)
