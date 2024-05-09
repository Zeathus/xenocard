extends GameAnimation

class_name AnimationEffectStart

var card: Card
var time: float

func _init(_card: Card):
	self.card = _card
	self.time = 0

func update(delta):
	if is_done():
		return
	if card.instance == null:
		finish()
		return
	var indicator: Node = card.instance.find_child("EffectIndicator")
	if time == 0:
		indicator.visible = true
	var scale: float = 1.0
	scale += (1.0 - min(time * 3, 1.0)) * 3
	indicator.scale = Vector2(scale, scale)
	indicator.modulate.a = min(time * 3, 1.0)
	if time >= 0.5:
		finish()
	time += delta
