extends Event

class_name EventRecover

var player: Player
var anon_card: Node2D
var amount: int

func _init(_game_board: GameBoard, _player: Player, _amount: int):
	super(_game_board)
	player = _player
	amount = _amount
	anon_card = game_board.find_child("AnonCard")

func get_name() -> String:
	return "Recover"

func on_start():
	broadcast()
	anon_card.global_position = player.field.get_lost_node().global_position
	anon_card.visible = true
	var recovered = player.recover(amount)
	for i in range(recovered):
		queue_event(EventAnimation.new(game_board,
			AnimationMove.new(anon_card, player.field.get_deck_node().global_position, 15)
		))

func on_finish():
	anon_card.visible = false

func process(delta):
	if pass_to_child("process", [delta]):
		return
	finish()

func broadcast():
	if game_board.is_server():
		var args: Array = [player, str(amount)]
		player.controller.broadcast_event(get_name(), args)
		player.get_enemy().controller.broadcast_event(get_name(), args)
