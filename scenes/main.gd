extends Node2D

var main_menu = load("res://scenes/main_menu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	Random.set_seed(randi())
	if OS.has_feature("dedicated_server") or OS.has_feature("display_server"):
		var server: TCGServer = TCGServer.new()
		add_child(server)
	else:
		add_child(main_menu.instantiate())
	load_card_data()

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

func load_card_data():
	CardData.load_cards()
	print("Loaded %d cards." % CardData.get_count())
