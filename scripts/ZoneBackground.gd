extends Sprite2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	region_rect.position += Vector2(-delta * 24, delta * 24)
