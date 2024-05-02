extends GameAnimation

class_name MoveAnimation

var node: Node2D
var original_distance: float
var destination: Vector2
var original_scale: Vector2
var target_scale: Vector2
var speed: int
var time: float

func _init(node: Node2D, destination: Vector2, speed: int):
	self.node = node
	self.destination = destination
	self.speed = speed
	self.time = 0
	original_scale = node.scale
	target_scale = node.scale
	if node.has_method("set_in_motion"):
		node.set_in_motion(true)

func update(delta):
	if is_done():
		return
	if time == 0:
		original_distance = destination.distance_to(node.global_position)
	time += delta
	var distance: Vector2 = destination - node.global_position
	var move: Vector2 = distance.normalized() * 100 * speed * delta
	if move.length() >= distance.length():
		node.global_position = destination
		node.scale = target_scale
		if node.has_method("set_in_motion"):
			node.set_in_motion(false)
		finish()
	else:
		node.global_position += move
		node.scale = original_scale * (distance.length() / original_distance) + \
			target_scale * ((original_distance - distance.length()) / original_distance)
	if time >= 2.0:
		node.scale = target_scale
		if node.has_method("set_in_motion"):
			node.set_in_motion(false)
		finish()
