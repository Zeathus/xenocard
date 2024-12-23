extends Node2D

var task = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if task and task[0] == "create_images":
		if len(task[1]) > 0:
			if task[3] == 0:
				task[5].show_card(task[2][0])
				task[3] = 1
			else:
				var img = task[4].get_texture().get_image()
				var path = "res://sprites/card_images_baked/%s.png" % task[1][0]
				DirAccess.make_dir_absolute(path.substr(0, path.rfind("/")))
				img.save_png(path)
				print("Saved '", path, "'")
				task[3] = 0
				task[1].pop_at(0)
				task[2].pop_at(0)
		else:
			remove_child(task[4])
			remove_child(task[5])
			task = null

func _on_button_exit_pressed():
	get_tree().quit()

func _on_button_decks_pressed():
	var decks_scene = load("res://scenes/deck_builder.tscn")
	get_parent().start_scene(decks_scene.instantiate())

func _on_button_solo_pressed():
	var solo_game_scene = load("res://scenes/solo_game.tscn")
	get_parent().start_scene(solo_game_scene.instantiate())

func _on_button_online_pressed() -> void:
	var online_game_scene = load("res://scenes/online_game.tscn")
	get_parent().start_scene(online_game_scene.instantiate())

func _on_button_tutorials_pressed() -> void:
	var tutorial_scene = load("res://tutorial/menu_tutorial.tscn")
	get_parent().start_scene(tutorial_scene.instantiate())

func _on_button_create_card_images_pressed() -> void:
	var sub_viewport = SubViewport.new()
	sub_viewport.size = Vector2(400, 600)
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	sub_viewport.transparent_bg = true
	add_child(sub_viewport)
	var card_display = load("res://objects/card_display.tscn").instantiate()
	card_display.turn_up()
	sub_viewport.add_child(card_display)
	card_display.position = Vector2(200, 300)
	card_display.scale = Vector2(0.5, 0.5)
	var images_to_make = CardData.data
	task = ["create_images", images_to_make.keys(), images_to_make.values(), 0, sub_viewport, card_display]
