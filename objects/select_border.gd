extends Line2D

var original_pos: Array[Vector2i]
var timer: float

func _ready():
	timer = 0.0
	for p in points:
		original_pos.push_back(Vector2i(p.x, p.y))

func _process(delta):
	if not visible:
		return
	timer += delta * 4
	if timer > PI * 2:
		timer -= PI * 2
	for i in range(20):
		var sine: float = timer
		if i % 2 == 0:
			sine += PI
		var point: Vector2 = points[i]
		point.x = original_pos[i].x
		point.y = original_pos[i].y
		# Top
		if i == 0 or i >= 16:
			point.y += sin(sine) * 16
		# Left
		if i >= 0 and i <= 6:
			point.x += sin(sine) * 16
		# Bottom
		if i >= 6 and i <= 10:
			point.y -= sin(sine) * 16
		# Right
		if i >= 10 and i <= 16:
			point.x -= sin(sine) * 16
		points[i] = point
