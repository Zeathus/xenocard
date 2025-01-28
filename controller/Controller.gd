extends Node2D

class_name Controller

enum Action {
	NONE = 0,
	END_PHASE = 1,
	MOVE = 2,
	EVENT = 3,
	SET = 4,
	BLOCK = 5,
	CONFIRM = 6,
	TARGET = 7,
	SEARCH = 8,
	SEARCH_JUNK = 9,
	DISCARD = 10,
	COUNTER = 11,
	MULLIGAN = 12
}

var game_board: GameBoard
var player: Player
var running: bool
var has_request: bool
var in_handling: bool
var semaphore: Semaphore
var finished: bool
var requested_actions: Array[Action]
var request_handlers: Array[Callable]
var request_args: Array
var waiting: bool
var response: int
var response_args: Array
var pause_time: float = 0

func _init(_game_board: GameBoard, _player: Player):
	game_board = _game_board
	player = _player
	running = false
	has_request = false
	in_handling = false
	semaphore = Semaphore.new()
	finished = false
	waiting = false
	response = -1

func start() -> void:
	running = true
	on_start()

func on_start() -> void:
	pass

func stop() -> void:
	finished = true
	running = false

func is_waiting() -> bool:
	var ret: bool = waiting
	return ret

func has_response() -> bool:
	var ret: bool = response != -1
	return ret

func request(actions: Array[Action], handlers: Array[Callable], args: Array = []):
	assert(len(actions) == len(handlers))
	while len(args) < len(handlers):
		args.push_back([])
	assert(not waiting and response == -1)
	requested_actions = actions
	request_handlers = handlers
	request_args = args
	response = -1
	waiting = true
	semaphore.post()

func receive():
	assert(not waiting and response != -1)
	# var action: Action = requested_actions[response]
	var handler: Callable = request_handlers[response]
	handler.callv(response_args)
	response = -1
	response_args.clear()

func _prepare_handling(delta: float, actions: Array[Action]):
	pass

func _handle_request(action: Action, args: Array) -> bool:
	return false

func _process(delta: float) -> void:
	if not running:
		return
	if not has_request and semaphore.try_wait():
		has_request = true
	if has_request and not in_handling:
		if waiting:
			var actions: Array[Action] = requested_actions.duplicate()
			if _prepare_handling(delta, actions):
				in_handling = true
	elif in_handling:
		var actions: Array[Action] = requested_actions.duplicate()
		for i in range(len(actions)):
			if _handle_request(actions[i], request_args[i]):
				response = i
				waiting = false
				break
		if not waiting:
			has_request = false
			in_handling = false
