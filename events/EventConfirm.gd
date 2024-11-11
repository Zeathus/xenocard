extends Event

class_name EventConfirm

static var confirm_scene = load("res://scenes/menu_confirm.tscn")
var player: Player
var message: String
var on_yes: Callable
var on_no: Callable
var event_yes: Event = null
var event_no: Event = null
var help: String
var menu = null
var wait_for_finish: bool = false
var card_preview: Card
var yes_only: bool = false

func _init(_game_board: GameBoard, _player: Player, _message: String, _on_yes, _on_no, _help: String="", _card: Card=null):
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
	card_preview = _card

func set_yes_only():
	yes_only = true

func get_name() -> String:
	return "Confirm"

func on_start():
	if player.has_controller():
		return
	menu = confirm_scene.instantiate()
	menu.set_message(message)
	menu.set_help(help)
	menu.set_card(card_preview)
	menu.set_handler(handle_answer)
	if yes_only:
		menu.set_yes_only()
	game_board.add_menu(menu)

func on_finish():
	pass

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
					[Controller.Action.CONFIRM],
					[func(x): handle_answer(x); wait_for_finish = true]
				)
	else:
		if menu and menu.is_done():
			game_board.remove_menu(menu)
			menu.finish()
			wait_for_finish = true

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
