extends Event

class_name EventConfirm

static var confirm_scene = preload("res://scenes/menu_confirm.tscn")
var player: Player
var message: String
var on_yes: Callable
var on_no: Callable
var event_yes: Event = null
var event_no: Event = null
var help: String
var menu = null

func _init(_game_board: GameBoard, _player: Player, _message: String, _on_yes, _on_no, _help: String=""):
	super(_game_board)
	player = _player
	message = _message
	if _on_yes is Callable:
		on_yes = _on_yes
	else:
		event_yes = _on_yes
	if _on_no is Callable:
		on_no = _on_no
	else:
		event_no = _on_no
	help = _help

func get_name() -> String:
	return "Confirm"

func on_start():
	menu = confirm_scene.instantiate()
	menu.set_message(message)
	menu.set_help(help)
	menu.set_handler(handle_answer)
	game_board.add_menu(menu)

func on_finish():
	game_board.remove_menu(menu)

func process(delta):
	if pass_to_child("process", [delta]):
		return
	if menu and menu.is_done():
		menu.finish()
		menu = null
	if menu == null and not has_children():
		finish()

func handle_answer(answer: bool):
	if answer:
		if event_yes:
			queue_event(event_yes)
		elif on_yes:
			on_yes.call()
	else:
		if event_no:
			queue_event(event_no)
		elif on_no:
			on_no.call()
