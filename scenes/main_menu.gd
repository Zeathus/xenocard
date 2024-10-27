extends Node2D

var decks_scene = load("res://scenes/deck_builder.tscn")
var solo_game_scene = load("res://scenes/solo_game.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_exit_pressed():
	get_tree().quit()

func _on_button_decks_pressed():
	get_parent().start_scene(decks_scene.instantiate())

func _on_button_solo_pressed():
	get_parent().start_scene(solo_game_scene.instantiate())
