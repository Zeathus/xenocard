extends Polygon2D

var time: float = 0

func _process(delta: float) -> void:
	if visible:
		time += delta * 2
		if time >= PI * 2:
			time -= PI * 2
		modulate.a = abs(sin(time))
	else:
		modulate.a = 0
		time = 0
