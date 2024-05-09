extends GameAnimation

class_name AnimationEffectEnd

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
	indicator.modulate.a = 1.0 - min(time * 4, 1.0)
	if time >= 0.25:
		indicator.visible = false
		finish()
	time += delta
