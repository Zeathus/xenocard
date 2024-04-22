extends GameAnimation

class_name AddToHandAnimation

var node: Node2D
var original_distance: float
var destination: Vector2
var original_scale: Vector2
var target_scale: Vector2
var speed: float
var time: float
var max_time: float = 0.5
var hand: GameHand
var hand_move: float
var hand_original_x_position: float

func _init(node: Node2D, hand: GameHand):
	self.node = node
	self.hand = hand
	self.time = 0
	var original_position: Vector2 = node.global_position
	destination = hand.get_new_card_position()
	hand_move = 64 if hand.global_rotation == 0 else -64
	if hand.size() >= 5:
		hand_move *= 2
	hand_original_x_position = hand.position.x
	hand.position.x += hand_move
	original_scale = node.scale
	target_scale = node.scale
	node.global_position = original_position
	if node.has_method("set_in_motion"):
		node.set_in_motion(true)

func update(delta):
	if is_done():
		return
	if time == 0:
		original_distance = destination.distance_to(node.global_position)
		speed = original_distance / max_time
	time += delta
	var distance: Vector2 = destination - node.global_position
	var move: Vector2 = distance.normalized() * speed * delta
	if move.length() >= distance.length():
		node.global_position = destination
		node.scale = target_scale
		hand.position.x = hand_original_x_position
		if node.has_method("set_in_motion"):
			node.set_in_motion(false)
		finish()
	else:
		node.global_position += move
		node.scale = original_scale * (distance.length() / original_distance) + \
			target_scale * ((original_distance - distance.length()) / original_distance)
		hand.position.x = hand_original_x_position + hand_move * (distance.length() / original_distance)
	if time >= 2.0:
		node.scale = target_scale
		hand.position.x = hand_original_x_position
		if node.has_method("set_in_motion"):
			node.set_in_motion(false)
		finish()
