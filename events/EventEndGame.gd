extends Event

class_name EventEndGame

var result: Enum.GameResult
var state: int = 0
var transition_turn: Label
var transition_player: AnimationPlayer

func _init(_game_board: GameBoard, _result: Enum.GameResult):
	super(_game_board)
	result = _result
	var phases_node: Node2D = game_board.find_child("Phases")
	transition_turn = phases_node.find_child("TransitionTurn")
	transition_player = phases_node.find_child("TransitionPlayer")

func get_name() -> String:
	return "EndGame"

func on_start():
	broadcast()

func on_finish():
	if game_board.tutorial and result == Enum.GameResult.TUTORIAL:
		game_board.tutorial.set_completed(true)
	game_board.end_scene()

func check_game_end():
	pass

func process(delta):
	if pass_to_child("process", [delta]):
		return
	match state:
		0:
			transition_turn.text = get_text()
			transition_player.play("NextTurn")
			state = 1
		1:
			if not transition_player.is_playing():
				state = 2
		2:
			finish()

func get_text() -> String:
	match result:
		Enum.GameResult.TIE:
			return "TIE"
		Enum.GameResult.P1_WIN:
			return "VICTORY" if (game_board.players[1].has_controller() and not game_board.players[0].has_controller()) else "P1 VICTORY"
		Enum.GameResult.P2_WIN:
			return "DEFEAT" if (game_board.players[1].has_controller() and not game_board.players[0].has_controller()) else "P2 VICTORY"
		Enum.GameResult.P1_FORFEIT:
			return "FORFEIT..." if (game_board.players[1].has_controller() and not game_board.players[0].has_controller()) else "P2 VICTORY"
		Enum.GameResult.P2_FORFEIT:
			return "ENEMY FORFEIT" if (game_board.players[1].has_controller() and not game_board.players[0].has_controller()) else "P1 VICTORY"
		Enum.GameResult.CANCELLED:
			return "CANCELLED"
		Enum.GameResult.TUTORIAL:
			return "TUTORIAL COMPLETE"
		Enum.GameResult.DISCONNECT:
			return "ENEMY DISCONNECTED"
	return "N/A"

func get_enemy_result() -> Enum.GameResult:
	match result:
		Enum.GameResult.P1_WIN:
			return Enum.GameResult.P2_WIN
		Enum.GameResult.P2_WIN:
			return Enum.GameResult.P1_WIN
		Enum.GameResult.P1_FORFEIT:
			return Enum.GameResult.P2_FORFEIT
		Enum.GameResult.P2_FORFEIT:
			return Enum.GameResult.P1_FORFEIT
	return result

func broadcast():
	if game_board.is_server():
		var args: Array[String] = [str(result)]
		game_board.players[0].controller.broadcast_event(get_name(), args)
		args = [str(get_enemy_result())]
		game_board.players[1].controller.broadcast_event(get_name(), args)
