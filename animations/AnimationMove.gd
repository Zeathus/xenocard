extends GameAnimation

class_name AnimationMove

var node: Node2D
var original_distance: float
var destination: Vector2
var original_scale: Vector2
var target_scale: Vector2
var speed: int
var time: float
var flip: bool
var flip_state: int = 0
var keep_in_motion: bool = false

func _init(node: Node2D, destination: Vector2, speed: int, flip: bool = false):
	self.node = node
	self.destination = destination
	self.speed = speed
	self.time = 0
	self.flip = flip
	original_scale = node.scale
	target_scale = node.scale
	if node.has_method("set_in_motion"):
		node.set_in_motion(true)

func update(delta):
	if is_done():
		return
	if flip:
		if node.animating():
			return
		if flip_state == 0:
			node.play_animation("Flip1")
			flip_state = 1
		elif flip_state == 1:
			node.flip()
			node.play_animation("Flip2")
			flip_state = 2
		else:
			flip = false
		return
	if time == 0:
		original_distance = destination.distance_to(node.global_position)
	time += delta
	var distance: Vector2 = destination - node.global_position
	var move: Vector2 = distance.normalized() * 100 * speed * delta
	if move.length() >= distance.length():
		node.global_position = destination
		node.scale = target_scale
		if not keep_in_motion:
			if node.has_method("set_in_motion"):
				node.set_in_motion(false)
		finish()
	else:
		node.global_position += move
		node.scale = original_scale * (distance.length() / original_distance) + \
			target_scale * ((original_distance - distance.length()) / original_distance)
	if time >= 2.0:
		node.scale = target_scale
		if not keep_in_motion:
			if node.has_method("set_in_motion"):
				node.set_in_motion(false)
		finish()
