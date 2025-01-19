extends Event

class_name EventIdentity

var online_id: String
var card_id: String
var awaited: bool

func _init(_game_board: GameBoard, _online_id: String, _card_id: String, _awaited: bool):
	online_id = _online_id
	card_id = _card_id
	awaited = _awaited
	super(_game_board)

func get_name() -> String:
	return "Identity"

func on_start():
	var card: Card = game_board.get_card_from_online_id(online_id)
	card.set_id(card_id)
	if awaited and card.instance.is_face_down():
		queue_event(EventAnimation.new(game_board, AnimationFlip.new(card)))

func on_finish():
	pass

func process(delta):
	if pass_to_child("process", [delta]):
		return
	finish()
