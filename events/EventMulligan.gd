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
	broadcast()
	if player.has_controller():
		return
	queue_event(EventConfirm.new(
		game_board,
		player,
		"Redraw your hand?",
		func(): do_mulligan(),
		func(): do_not_mulligan(),
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
					[func(): do_mulligan(), func(): do_not_mulligan()],
					[[remaining], []]
				)

func do_mulligan():
	if player.get_enemy().is_online():
		player.get_enemy().controller.send_action(Controller.Action.MULLIGAN)
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

func do_not_mulligan():
	if player.get_enemy().is_online():
		player.get_enemy().controller.send_action(Controller.Action.END_PHASE)
	wait_for_finish = true

func broadcast():
	if game_board.is_server():
		print("Broadcasting ", get_name())
		player.controller.broadcast_event(get_name(), [player, str(remaining)])
		player.get_enemy().controller.broadcast_event(get_name(), [player, str(remaining)])
