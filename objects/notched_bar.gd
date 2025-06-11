extends Control

var value: int = 0
var max_value: int = 0
@export var color_on: Color = Color(0, 0.5, 0)
var color_off: Color = Color(0.25, 0.25, 0.25)

func _draw():
	if max_value == 0:
		return
	var start_x = 4
	var total_width: float = 124.0
	var spacing_size: int = 4
	if max_value > 10:
		spacing_size = 2
	if max_value > 20:
		spacing_size = 1
	var total_spacing: float = (max_value - 1) * spacing_size
	var width: float = (total_width - total_spacing) / max_value
	var style_box = StyleBoxFlat.new()
	style_box.set_corner_radius_all(2)
	for i in range(max_value):
		style_box.bg_color = color_on if value > i else color_off
		draw_style_box(style_box, Rect2(start_x + (width + spacing_size) * i, 3, width, 24))
