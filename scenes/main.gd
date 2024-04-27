extends Node2D

var main_menu = preload("res://scenes/main_menu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(main_menu.instantiate())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start_scene(scene):
	for c in get_children():
		if not c is Camera2D:
			c.visible = false
	add_child(scene)

func end_scene():
	var last_child = get_child(get_child_count() - 1)
	last_child.queue_free()
	remove_child(last_child)
	get_child(get_child_count() - 1).visible = true
