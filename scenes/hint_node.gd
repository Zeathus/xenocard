extends Node2D

class_name HintNode

enum Position {
	CENTER,
	ABOVE_HAND
}

var time: float = 0
var target_a: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate.a = target_a
	visible = false
	set_pos(Position.CENTER)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target_a < modulate.a:
		modulate.a -= delta * 2
		if modulate.a <= target_a:
			modulate.a = target_a
	elif target_a > modulate.a:
		modulate.a += delta * 2
		if modulate.a >= target_a:
			modulate.a = target_a
	visible = (modulate.a > 0)
	if visible:
		time += delta
		if time >= PI * 2:
			time -= PI * 2
		$HintContainer.position.y = sin(time * 4) * 4 - 24
	else:
		time = 0

func set_pos(pos: Position):
	match pos:
		Position.CENTER:
			position = Vector2(0, 0)
		Position.ABOVE_HAND:
			position = Vector2(0, 360)

func set_hint(hint: String):
	$HintContainer/HintText.text = hint

func fade_in() -> void:
	target_a = 1

func fade_out() -> void:
	target_a = 0
