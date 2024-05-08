extends Event

class_name EventRecover

var player: Player
var anon_card: Node2D

func _init(_game_board: GameBoard, _player: Player):
	super(_game_board)
	player = _player
	anon_card = game_board.find_child("AnonCard")

func get_name() -> String:
	return "Recover"

func on_start():
	anon_card.global_position = player.field.get_lost_node().global_position
	anon_card.visible = true
	queue_event(EventAnimation.new(game_board,
		AnimationMove.new(anon_card, player.field.get_deck_node().global_position, 15)
	))

func on_finish():
	anon_card.visible = false

func process(delta):
	if pass_to_child("process", [delta]):
		return
	finish()
