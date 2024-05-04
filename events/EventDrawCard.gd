extends Event

class_name EventDrawCard

var player: Player
var card: Card
var speed: int

func _init(_game_board: GameBoard, _player: Player, _speed: int = 1):
	super(_game_board)
	player = _player
	speed = _speed

func get_name() -> String:
	return "DrawCard"

func on_start():
	var card = player.draw()
	if card == null:
		return
	game_board.prepare_card(card)
	player.hand.add_card(card)
	card.instance.global_position = player.field.get_deck_node().global_position
	queue_event(EventAnimation.new(game_board,
		AnimationAddToHand.new(card.instance, player.hand, speed)
	))

func on_finish():
	player.hand.refresh()

func process(delta):
	if pass_to_child("process", [delta]):
		return
	finish()
