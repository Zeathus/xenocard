extends Node2D

signal selected(zone: Card.Zone, index: int)

@export var type: Card.Zone
@export var index: int

func _on_area_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == 1:
				selected.emit(type, index)
