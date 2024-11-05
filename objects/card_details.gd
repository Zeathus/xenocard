extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CardNode/Content/Text.mouse_filter = Control.MouseFilter.MOUSE_FILTER_PASS
