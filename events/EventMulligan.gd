extends Event

class_name EventMulligan

var player: Player
var card: Card
var remaining: int
var wait_for_finish: bool = false

func _init(_game_board: GameBoard, _player: Player, _remaining: int = 3):
	super(_game_board)
	player = _player
	remaining = _remaining

func get_name() -> String:
	return "Mulligan"

func on_start():
	if player.has_controller():
		return
	queue_event(EventConfirm.new(
		game_board,
		player,
		"Redraw you hand?",
		func(): do_mulligan(),
		func(): wait_for_finish = true,
		"Do you want to keep this hand?\nYou have %d redraws remaining." % remaining
	))

func on_finish():
	player.hand.refresh()

func process(delta):
	if pass_to_child("process", [delta]):
		return
	if wait_for_finish:
		finish()

func do_mulligan():
	while player.hand.size() > 0:
		var card: Card = player.hand.cards.back()
		player.hand.remove(card)
		player.deck.add_top(card)
	player.deck.shuffle()
	for i in range(5):
		var card = player.draw()
		if card == null:
			break
		game_board.prepare_card(card)
		player.hand.add_card(card)
		var flip = card.instance.is_face_up()
		if flip:
			card.instance.turn_down()
		card.instance.global_position = player.field.get_deck_node().global_position
		queue_event(EventAnimation.new(game_board,
			AnimationAddToHand.new(card.instance, player.hand, 2, flip)
		))
	if remaining > 1:
		queue_event(EventMulligan.new(game_board, player, remaining - 1))
