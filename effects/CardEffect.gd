class_name CardEffect

var game_board: GameBoard
var effector: Card
var trigger: Trigger
var requirements: Array = []
var effects: Array[Effect] = []
var stackable: bool = true

func _init(_game_board: GameBoard, _card: Card, _data):
	game_board = _game_board
	effector = _card
	parse(_data)

func parse(_data):
	if _data is String:
		effects.push_back(Effect.get_effect_class(_data).new(game_board, effector, effector, _data))
	elif _data is Dictionary:
		for e in _data["effect"]:
			effects.push_back(Effect.get_effect_class(e).new(game_board, effector, effector, e))
		if "requirement" in _data:
			for r in _data["requirement"]:
				requirements.push_back(Requirement.get_requirement_class(r).new(game_board, effector, effector, r))
		if "stackable" in _data:
			stackable = _data["stackable"]

func is_stackable() -> bool:
	return stackable

func is_active() -> bool:
	return not effector.downed
