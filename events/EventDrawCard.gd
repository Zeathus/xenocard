extends Event

class_name EventDrawCard

var player: Player
var card: Card

func _init(_game_board: GameBoard, _player: Player):
	super(_game_board)
	player = _player

func get_name() -> String:
	return "DrawCard"

func on_start():
	card = game_board.prepare_card(player.draw())
	player.hand.add_card(card)
	card.instance.global_position = player.field.get_deck_node().global_position
	queue_event(EventAnimation.new(game_board,
		AddToHandAnimation.new(card.instance, player.hand)
	))

func on_finish():
	player.hand.refresh()

func process(delta):
	if pass_to_child("process", [delta]):
		return
	finish()
