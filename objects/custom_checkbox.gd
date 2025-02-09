extends Node2D

signal toggled(new_state: int)

@export var state: int = 0
@export var three_state: bool = false

func _ready() -> void:
	refresh()

func refresh():
	$Enabled.visible = false
	$Disabled.visible = false
	if state == 1:
		$Enabled.visible = true
	elif state == 2:
		$Disabled.visible = true

func is_none() -> bool:
	return state == 0

func is_on() -> bool:
	return state == 1

func is_off() -> bool:
	return state == 2

func _on_check_box_pressed() -> void:
	$CheckBox.button_pressed = false
	state += 1
	if state > 2 if three_state else state > 1:
		state = 0
	refresh()
	toggled.emit(state)
