extends Event

class_name EventSearch

static var browse_scene = preload("res://scenes/menu_browse_cards.tscn")
var player: Player
var filter: CardFilter
var message: String
var menu = null

func _init(_game_board: GameBoard, _player: Player, _filter: CardFilter, _message: String):
	super(_game_board)
	player = _player
	filter = _filter
	message = _message

func get_name() -> String:
	return "Search"

func on_start():
	menu = browse_scene.instantiate()
	menu.set_message(message)
	menu.set_filter(filter)
	menu.set_cards(player.deck.cards)
	menu.set_handler(handle_card)
	game_board.add_menu(menu)

func on_finish():
	game_board.remove_menu(menu)

func process(delta):
	if pass_to_child("process", [delta]):
		return
	if menu.is_done():
		menu.finish()
		finish()

func handle_card(index: int, card: Card):
	if index != -1:
		card = player.deck.draw_at(index)
		game_board.refresh()
		player.hand.add_card(game_board.prepare_card(card))
	player.deck.shuffle()
