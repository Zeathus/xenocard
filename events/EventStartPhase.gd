extends Event

class_name EventStartPhase

var player: Player
var phase: Enum.Phase
var state: int = 0
var label_phase: Label
var label_next_phase: Label

func _init(_game_board: GameBoard, _player: Player, _phase: Enum.Phase):
	player = _player
	phase = _phase
	super(_game_board)
	var phases_node: Node2D = game_board.find_child("Phases")
	label_phase = phases_node.find_child("Phase")
	label_next_phase = phases_node.find_child("NextPhase")

func get_name() -> String:
	return "StartPhase"

func on_start():
	pass

func on_finish():
	for label in [label_phase, label_next_phase]:
		label.label_settings.font_color.a = 1.0
		label.label_settings.outline_color.a = 1.0

func process(delta):
	if pass_to_child("process", [delta]):
		return
	match state:
		0:
			for label in [label_phase, label_next_phase]:
				label.label_settings.font_color.a = 1.0
				label.label_settings.outline_color.a = 1.0
			state = 1
		1:
			for label in [label_phase, label_next_phase]:
				label.label_settings.font_color.a -= delta * 4
				label.label_settings.outline_color.a -= delta * 4
			if label_phase.label_settings.font_color.a <= 0:
				label_phase.text = get_phase_text(phase)
				label_next_phase.text = "➔ " + get_phase_text(get_next_phase(phase))
				state = 2
		2:
			for label in [label_phase, label_next_phase]:
				label.label_settings.font_color.a = 0
				label.label_settings.outline_color.a = 0
			state = 3
		3:
			for label in [label_phase, label_next_phase]:
				label.label_settings.font_color.a += delta * 4
				label.label_settings.outline_color.a += delta * 4
			if label_phase.label_settings.font_color.a >= 1:
				state = 4
		4:
			finish()

func get_phase_text(_phase: Enum.Phase) -> String:
	var pid = player.id + 1
	if phase != _phase:
		if phase == Enum.Phase.SET:
			pid = pid % 2 + 1
		elif phase == Enum.Phase.BLOCK:
			pid = pid % 2 + 1
	match _phase:
		Enum.Phase.DRAW:
			return "%dP Draw Phase" % pid
		Enum.Phase.MOVE:
			return "%dP Move Phase" % pid
		Enum.Phase.EVENT:
			return "%dP Event Phase" % pid
		Enum.Phase.SET:
			return "%dP Set Phase" % pid
		Enum.Phase.BLOCK:
			return "%dP Block Phase" % pid
		Enum.Phase.BATTLE:
			return "%dP Battle Phase" % pid
		Enum.Phase.ADJUST:
			return "%dP Adjust Phase" % pid
	return "N/A"

func get_next_phase(_phase: Enum.Phase) -> Enum.Phase:
	match _phase:
		Enum.Phase.DRAW:
			return Enum.Phase.MOVE
		Enum.Phase.MOVE:
			return Enum.Phase.EVENT
		Enum.Phase.EVENT:
			return Enum.Phase.SET
		Enum.Phase.SET:
			return Enum.Phase.BLOCK
		Enum.Phase.BLOCK:
			return Enum.Phase.BATTLE
		Enum.Phase.BATTLE:
			return Enum.Phase.ADJUST
		Enum.Phase.ADJUST:
			return Enum.Phase.DRAW
	return Enum.Phase.ADJUST
