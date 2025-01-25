class_name TutorialHint

var type: int
var pos: HintNode.Position
var text: String
var exec: Callable = do_nothing

func _init(_type: int, _text: String, _pos: HintNode.Position = HintNode.Position.CENTER) -> void:
	type = _type
	text = _text
	pos = _pos

func do_nothing(game_board: GameBoard):
	pass
