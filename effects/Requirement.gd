class_name Requirement

var game_board: GameBoard
var effector: Card
var affected: Card
var requirement_name: String

func _init(_game_board: GameBoard, _effector: Card, _affected: Card, _requirement: String):
	game_board = _game_board
	effector = _effector
	affected = _affected
	if "(" in _requirement and ")" in _requirement and _requirement.find("(") < _requirement.rfind(")"):
		var argv = _requirement.substr(_requirement.find("(") + 1, _requirement.rfind(")") - _requirement.find("(") - 1)
		requirement_name = _requirement.substr(0, _requirement.find("("))
		post_init(argv.split(","))
	else:
		requirement_name = _requirement

static func get_requirement_class(_requirement: String) -> Object:
	if "(" in _requirement:
		_requirement = _requirement.substr(0, _requirement.find("("))
	var requirement_script: GDScript = load("res://effects/Requirement%s.gd" % _requirement)
	if requirement_script == null:
		print("Failed to find requirement '%s'" % _requirement)
		return Effect
	return requirement_script

func post_init(argv: Array[String]):
	pass
