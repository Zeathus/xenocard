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
		"Redraw your hand?",
		func(): do_mulligan(),
		func(): wait_for_finish = true,
		"Do you want to redraw your hand?\nYou have %d redraws remaining." % remaining
	))

func on_finish():
	player.hand.refresh()

func process(delta):
	if pass_to_child("process", [delta]):
		return
	if wait_for_finish:
		finish()
	elif player.has_controller():
		if not player.controller.is_waiting():
			if player.controller.has_response():
				player.controller.receive()
			else:
				player.controller.request(
					[Controller.Action.MULLIGAN, Controller.Action.END_PHASE],
					[func(): do_mulligan(), func(): wait_for_finish = true],
					[[remaining], []]
				)

func do_mulligan():
	while player.hand.size() > 0:
		var card: Card = player.hand.cards.back()
		player.hand.remove(card)
		player.deck.add_top(card)
	player.deck.shuffle()
	for i in range(5):
		queue_event(EventDrawCard.new(game_board, player, 2))
	if remaining > 1:
		queue_event(EventMulligan.new(game_board, player, remaining - 1))
	wait_for_finish = true