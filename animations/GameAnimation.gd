class_name GameAnimation

var next_animation: GameAnimation = null
var on_finish: Callable
var on_finish_params: Array
var done: bool = false

func _init():
	pass

func update(delta):
	pass

func set_on_finish(callable, params=[]):
	on_finish = callable
	on_finish_params = params

func finish():
	if is_done():
		return
	if on_finish != null:
		on_finish.callv(on_finish_params)
	done = true

func is_done() -> bool:
	return done

func next():
	return next_animation

func set_next(anim: GameAnimation):
	next_animation = anim

func insert_next(anim: GameAnimation):
	var old_next = next_animation
	next_animation = anim
	anim.next_animation = old_next
