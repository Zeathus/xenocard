extends GameAnimation

class_name AnimationFlip

var card: Card
var flip_state: int = 0

func _init(_card: Card):
	self.card = _card

func update(delta):
	if is_done():
		return
	if card.instance.animating():
		return
	if flip_state == 0:
		card.instance.play_animation("Flip1")
		flip_state = 1
	elif flip_state == 1:
		card.instance.flip()
		card.instance.play_animation("Flip2")
		flip_state = 2
	else:
		finish()
