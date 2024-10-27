extends Node2D

var game_scene = load("res://scenes/game_board.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	load_decks($P1/Deck, $P1/DeckPreset.button_pressed)
	load_decks($P2/Deck, $P2/DeckPreset.button_pressed)
	refresh()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func refresh():
	$ButtonStart.disabled = get_deck(0) == "" or get_deck(1) == ""

func load_decks(node: OptionButton, presets: bool = false):
	node.clear()
	var decks: Array[String]
	if presets:
		decks = DeckData.list_presets()
	else:
		decks = DeckData.list_decks()
	for deck in decks:
		node.add_item(deck)

func get_deck(player_id: int):
	var node: OptionButton = [$P1/Deck, $P2/Deck][player_id]
	return node.get_item_text(node.get_selected_id())

func _on_button_start_pressed():
	var game = game_scene.instantiate()
	add_player_options(game, $P1)
	add_player_options(game, $P2)
	game.game_options["reveal_hands"] = $Options/RevealHands.button_pressed
	get_parent().start_scene(game)

func add_player_options(game: GameBoard, node: Node):
	var options = {
		"deck": {
			"name": get_deck(len(game.player_options)),
			"preset": node.find_child("DeckPreset").button_pressed
		},
		"ai": node.find_child("ControllerAI").button_pressed
	}
	game.player_options.push_back(options)

func _on_button_exit_pressed():
	get_parent().end_scene()

func _on_p1_deck_preset_toggled(toggled_on):
	load_decks($P1/Deck, toggled_on)
	refresh()

func _on_p2_deck_preset_toggled(toggled_on):
	load_decks($P2/Deck, toggled_on)
	refresh()

func _on_deck_item_selected(index):
	refresh()
