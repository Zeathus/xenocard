class_name Event

var game_board: GameBoard
var started: bool = false
var parent: Event
var children: Array[Event] = []
var blocking: bool = true
var finished: bool = false
var success: bool = true
var sort_index: int = 0
var broadcasted: bool = true

func _init(_game_board: GameBoard):
	game_board = _game_board

func get_priority() -> int:
	return 0

func get_sub_priority() -> int:
	return 0

func get_name() -> String:
	return "N/A"

func start():
	if not started:
		on_start()
		started = true

func on_start():
	pass

func finish():
	if not finished:
		on_finish()
		finished = true
		check_game_end()

func on_finish():
	pass

func check_game_end():
	if game_board.players[0].deck.size() == 0 and game_board.players[1].deck.size() == 0:
		game_board.end_game(Enum.GameResult.TIE)
	elif game_board.players[0].deck.size() == 0:
		game_board.end_game(Enum.GameResult.P2_WIN)
	elif game_board.players[1].deck.size() == 0:
		game_board.end_game(Enum.GameResult.P1_WIN)

func pass_to_child(method, arguments=[]):
	if is_done():
		return true
	if not has_started():
		start()
	var blocked: bool = false
	for c in children:
		c.callv(method, arguments)
		if c.blocking:
			blocked = true
			break
	if children.any(func(x): return x.is_done()):
		children = children.filter(func(x):
			return not x.is_done()
		)
	return blocked

func process(delta):
	if pass_to_child("process", [delta]):
		return
	finish()

func cancel():
	success = false
	finish()

func can_cancel() -> bool:
	return false

func is_done():
	return finished

func has_started():
	return started

func has_children():
	return len(children) > 0

func adopt_children(event: Event):
	for c in event.children:
		c.parent = self
		children.push_back(c)
	event.children.clear()

func adopt_all_children(event: Event):
	for c in event.children:
		c.parent = self
		adopt_all_children(c)
		children.push_back(c)
	event.children.clear()

func sort_children():
	for i in range(len(children)):
		children[i].sort_index = i
	children.sort_custom(func(a: Event, b: Event):
		if a.get_priority() > b.get_priority():
			return true
		elif a.get_priority() < b.get_priority():
			return false
		if a.get_sub_priority() > b.get_sub_priority():
			return true
		elif a.get_sub_priority() < b.get_sub_priority():
			return false
		return a.sort_index < b.sort_index
	)

func queue_event(event: Event):
	if event.broadcasted and game_board.is_client():
		event = EventOnlineClient.new(game_board, game_board.client, event)
	if game_board.is_tutorial() and self is not EventHint:
		var hint: TutorialHint = game_board.tutorial.get_hint(game_board.turn_count, event)
		if hint != null:
			hint.exec.call(game_board)
			if hint.type == 0:
				event = EventHint.new(game_board, event, hint.text, hint.pos)
			elif hint.type == 1:
				var confirm_event = EventConfirm.new(game_board, game_board.players[0], "Tutorial", Callable(), Callable(), hint.text)
				confirm_event.set_yes_only()
				confirm_event.set_timeout(0)
				children.push_back(confirm_event)
	event.parent = self
	children.push_back(event)

func broadcast_player(player: Player):
	if game_board.is_server():
		Logger.i("Broadcasting %s" % get_name())
		player.controller.broadcast_event(get_name(), [player])
		player.get_enemy().controller.broadcast_event(get_name(), [player])

func broadcast():
	if game_board.is_server():
		Logger.i("Broadcasting %s" % get_name())
		game_board.get_turn_player().controller.broadcast_event(get_name())
		game_board.get_turn_enemy().controller.broadcast_event(get_name())

func on_hand_card_selected(hand: GameHand, card: Card):
	if pass_to_child("on_hand_card_selected", [hand, card]):
		return

func on_zone_selected(field: GameField, zone_owner: Player, zone: Enum.Zone, index: int):
	if pass_to_child("on_zone_selected", [field, zone_owner, zone, index]):
		return

func on_end_phase_pressed():
	pass

func stop_on_game_end() -> bool:
	return true

func can_end_phase() -> bool:
	return false
