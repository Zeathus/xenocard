extends Node2D

var tutorials: Array[Tutorial] = [
	Tutorial1PlayingCards.new(),
	Tutorial1PlayingCards.new(),
	Tutorial1PlayingCards.new()
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_tutorial_list()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setup_tutorial_list():
	var container: VBoxContainer = $List/ScrollContainer/VBoxContainer
	var y_pos = 0
	for tutorial in tutorials:
		var row: Label = Label.new()
		row.text = tutorial.get_name()
		y_pos += 100
		container.add_child(row)
	container.custom_minimum_size.y = y_pos

func _on_button_exit_pressed() -> void:
	get_parent().end_scene()
