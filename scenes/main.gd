extends Node2D

var main_menu = load("res://scenes/main_menu.tscn")
var last_game_result: Enum.GameResult = Enum.GameResult.NONE

# Called when the node enters the scene tree for the first time.
func _ready():
	for argument in OS.get_cmdline_args():
		# Parse valid command-line arguments into a dictionary
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			match key_value[0].lstrip("--"):
				"pid":
					Logger.id = key_value[1]
	if OS.has_feature("fixed_seed"):
		Random.set_seed(1)
	else:
		randomize()
		Random.set_seed(randi())
	if OS.has_feature("dedicated_server") or OS.has_feature("display_server"):
		var server: TCGServer = TCGServer.new()
		add_child(server)
	else:
		Options.load()
		add_child(main_menu.instantiate())
		$MenuBg.visible = true
	load_card_data()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start_scene(scene):
	for c in get_children():
		if c is not Camera2D and c != $MenuBg:
			c.visible = false
	add_child(scene)

func end_scene():
	var last_child = get_child(get_child_count() - 1)
	last_child.queue_free()
	remove_child(last_child)
	get_child(get_child_count() - 1).visible = true

func load_card_data():
	CardData.load_cards()
	Logger.i("Loaded %d cards." % CardData.get_count())
