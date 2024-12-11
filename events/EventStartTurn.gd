extends Event

class_name EventStartTurn

var player: Player
var state: int = 0
var transition_turn: Label
var transition_player: AnimationPlayer

func _init(_game_board: GameBoard, _player: Player):
	player = _player
	super(_game_board)
	var phases_node: Node2D = game_board.find_child("Phases")
	transition_turn = phases_node.find_child("TransitionTurn")
	transition_player = phases_node.find_child("TransitionPlayer")

func get_name() -> String:
	return "StartTurn"

func on_start():
	pass

func on_finish():
	pass

func process(delta):
	if pass_to_child("process", [delta]):
		return
	match state:
		0:
			transition_turn.text = "P" + str(player.id + 1) + "'S TURN"
			transition_player.play("NextTurn")
			state = 1
		1:
			if not transition_player.is_playing():
				state = 2
		2:
			if game_board.turn_count <= 2:
				queue_event(EventMulligan.new(game_board, player))
			state = 3
		3:
			finish()
