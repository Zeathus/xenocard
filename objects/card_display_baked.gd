extends Node2D

signal selected(button_index: int)
signal on_hover()

@export var selectable: bool = true
var original_scale: Vector2
var original_z: int
var is_hovering: bool = false
var old_is_hovering: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	original_scale = $Content.scale
	original_z = z_index

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if old_is_hovering != is_hovering:
		old_is_hovering = is_hovering
		if is_hovering:
			$Content.scale = original_scale * 1.25
			$Content.rotation = -global_rotation
		else:
			$Content.scale = original_scale
			$Content.rotation = 0
	z_index = original_z
	if is_hovering:
		z_index += 1

func show_card(card: CardData):
	$Content/Image.texture = card.get_baked_image()

func is_face_down() -> bool:
	return $Back.visible

func is_face_up() -> bool:
	return not $Back.visible

func turn_down():
	$Back.visible = true

func turn_up():
	$Back.visible = false

func flip():
	$Back.visible = !$Back.visible

func _on_panel_mouse_entered():
	on_hover.emit()
	if !selectable:
		return
	is_hovering = true

func _on_panel_mouse_exited():
	is_hovering = false

func _on_panel_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if selectable and event.button_index == 1 or event.button_index == 2:
				selected.emit(event.button_index)
