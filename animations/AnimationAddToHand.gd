extends GameAnimation

class_name AnimationAddToHand

var node: Node2D
var speed: float
var time: float
var max_time: float = 0.5
var hand: GameHand
var flip: bool
var flipped: bool = false

func _init(node: Node2D, hand: GameHand, flip: bool = false):
	self.node = node
	self.hand = hand
	self.time = 0
	self.flip = flip

func update(delta):
	if is_done():
		return
	if time == 0:
		if flip:
			node.play_animation("Flip1")
	if flip and not flipped and not node.animating():
		node.flip()
		node.play_animation("Flip2")
		flipped = true
		finish()
	elif not flip and time > 0.15:
		finish()
	time += delta
