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
var thread: Thread
var mutex: Mutex
var semaphore: Semaphore
var finished: bool
var requested_actions: Array[Action]
var request_handlers: Array[Callable]
var request_args: Array
var waiting: bool
var response: int
var response_args: Array

func _init(_game_board: GameBoard, _player: Player):
	game_board = _game_board
	player = _player
	thread = null
	mutex = Mutex.new()
	semaphore = Semaphore.new()
	finished = false
	waiting = false
	response = -1

func start() -> void:
	if thread:
		return
	thread = Thread.new()
	thread.start(_main)

func on_start() -> void:
	pass

func stop() -> void:
	mutex.lock()
	finished = true
	mutex.unlock()
	semaphore.post()
	thread.wait_to_finish()
	thread = null

func is_waiting() -> bool:
	mutex.lock()
	var ret: bool = waiting
	mutex.unlock()
	return ret

func has_response() -> bool:
	mutex.lock()
	var ret: bool = response != -1
	mutex.unlock()
	return ret

func request(actions: Array[Action], handlers: Array[Callable], args: Array = []):
	assert(len(actions) == len(handlers))
	while len(args) < len(handlers):
		args.push_back([])
	mutex.lock()
	assert(not waiting and response == -1)
	requested_actions = actions
	request_handlers = handlers
	request_args = args
	response = -1
	waiting = true
	mutex.unlock()
	semaphore.post()

func receive():
	mutex.lock()
	assert(not waiting and response != -1)
	# var action: Action = requested_actions[response]
	var handler: Callable = request_handlers[response]
	handler.callv(response_args)
	response = -1
	response_args.clear()
	mutex.unlock()

func _prepare_handling(actions: Array[Action]):
	pass

func _handle_request(action: Action, args: Array) -> bool:
	return false

func _main():
	on_start()
	while true:
		semaphore.wait()
		mutex.lock()
		if finished:
			mutex.unlock()
			return
		if waiting:
			var actions: Array[Action] = requested_actions.duplicate()
			mutex.unlock()
			_prepare_handling(actions)
			for i in range(len(actions)):
				if _handle_request(actions[i], request_args[i]):
					mutex.lock()
					response = i
					waiting = false
					break
			if not waiting:
				mutex.unlock()
		else:
			mutex.unlock()
