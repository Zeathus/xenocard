extends Event

class_name EventSearchJunk

static var browse_scene = load("res://scenes/menu_browse_cards.tscn")
var player: Player
var filter: CardFilter
var message: String
var menu = null
var wait_for_finish: bool = false
var handler: Callable
var forced: bool = false

func _init(_game_board: GameBoard, _player: Player, _filter: CardFilter, _message: String, _handler: Callable = Callable(self, "handle_card")):
	super(_game_board)
	player = _player
	filter = _filter
	message = _message
	handler = _handler

func get_name() -> String:
	return "SearchJunk"

func on_start():
	broadcast()
	if player.has_controller():
		return
	menu = browse_scene.instantiate()
	menu.set_message(message)
	menu.set_filter(filter)
	menu.set_cards(player.junk.cards)
	menu.set_handler(handler)
	menu.set_forced(forced)
	game_board.add_menu(menu)

func on_finish():
	if player.has_controller():
		return
	game_board.remove_menu(menu)

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
					[Controller.Action.SEARCH_JUNK],
					[func(x, y): handler.call(x, y); wait_for_finish = true],
					[[filter]]
				)
	else:
		if menu and menu.is_done():
			menu.finish()
			wait_for_finish = true

func handle_card(index: int, card: Card):
	if player.get_enemy().is_online():
		var args: Array[String] = [str(index)]
		player.get_enemy().controller.send_action(Controller.Action.SEARCH_JUNK, args)
	if index != -1:
		card = player.junk.draw_at(index)
		game_board.refresh()
		game_board.prepare_card(card)
		player.hand.add_card(card)
		card.instance.global_position = player.field.get_junk_node().global_position
		queue_event(EventAnimation.new(game_board,
			AnimationAddToHand.new(card.instance, player.hand)
		))

func broadcast():
	if game_board.is_server():
		var args: Array = [player, filter.string]
		player.controller.broadcast_event(get_name(), args)
		player.get_enemy().controller.broadcast_event(get_name(), args)
