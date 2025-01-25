extends Node2D

signal click_tutorial(tutorial: Tutorial)

var tutorial: Tutorial

func set_tutorial(_tutorial: Tutorial):
	tutorial = _tutorial
	$Button.text = tutorial.get_name()
	$Complete.visible = tutorial.is_completed()

func _on_button_pressed() -> void:
	click_tutorial.emit(tutorial)

func set_pressed(val: bool) -> void:
	$Button.button_pressed = val
