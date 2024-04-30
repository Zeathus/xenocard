class_name Controller

var thread: Thread
var mutex: Mutex
var semaphore: Semaphore
var finished: bool

func _init():
	thread = null
	mutex = Mutex.new()
	semaphore = Semaphore.new()
	finished = false

func start():
	if thread:
		return
	thread = Thread.new()
	thread.start(_main)

func stop():
	mutex.lock()
	finished = true
	mutex.unlock()
	semaphore.post()
	thread.wait_to_finish()
	thread = null

func _main():
	while true:
		semaphore.wait()
		mutex.lock()
		if finished:
			return
		mutex.unlock()
