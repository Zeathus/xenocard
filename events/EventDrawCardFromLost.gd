extends Event

class_name EventDrawCardFromLost

var player: Player
var card: Card

func _init(_game_board: GameBoard, _player: Player):
	super(_game_board)
	player = _player

func get_name() -> String:
	return "DrawCardFromLost"

func on_start():
	card = player.draw_lost()
	if card == null:
		return
	game_board.prepare_card(card)
	player.hand.add_card(card)
	var flip = card.instance.is_face_up()
	if flip:
		card.instance.turn_down()
	card.instance.global_position = player.field.get_lost_node().global_position
	queue_event(EventAnimation.new(game_board,
		AnimationAddToHand.new(card.instance, player.hand, flip)
	))

func on_finish():
	player.hand.refresh()

func process(delta):
	if pass_to_child("process", [delta]):
		return
	finish()
