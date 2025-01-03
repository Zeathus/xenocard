extends Event

class_name EventIdentity

var online_id: String
var card_id: String

func _init(_game_board: GameBoard, _online_id: String, _card_id: String):
	online_id = _online_id
	card_id = _card_id
	super(_game_board)

func get_name() -> String:
	return "Identity"

func on_start():
	game_board.get_card_from_online_id(online_id).set_id(card_id)

func on_finish():
	pass

func process(delta):
	if pass_to_child("process", [delta]):
		return
	finish()
