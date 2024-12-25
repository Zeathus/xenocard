extends Node2D

var game_scene = load("res://scenes/game_board.tscn")
var client: TCGClient = null

# Called when the node enters the scene tree for the first time.
func _ready():
	load_decks($P1/Deck, $P1/DeckPreset.button_pressed)
	refresh()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if client == null:
		return
	if client.state == TCGClient.ClientState.AWAIT_DECK:
		client.send_deck(Deck.load(get_deck(), $P1/DeckPreset.button_pressed))
	elif client.state == TCGClient.ClientState.START_GAME:
		client.state = TCGClient.ClientState.PLAYING
		var game = game_scene.instantiate()
		game.game_options["reveal_hands"] = $Options/RevealHands.button_pressed
		game.game_options["online"] = "client"
		game.client = client
		get_parent().start_scene(game)

func refresh():
	$ButtonStart.disabled = get_deck() == ""

func load_decks(node: OptionButton, presets: bool = false):
	node.clear()
	var decks: Array[String]
	if presets:
		decks = DeckData.list_presets()
	else:
		decks = DeckData.list_decks()
	for deck in decks:
		node.add_item(deck)

func get_deck():
	var node: OptionButton = $P1/Deck
	return node.get_item_text(node.get_selected_id())

func _on_button_start_pressed():
	var game = game_scene.instantiate()
	game.game_options["reveal_hands"] = false
	client = TCGClient.new()
	add_child(client)
	$ButtonStart.text = "Waiting for game..."
	$ButtonStart.disabled = true

func _on_button_exit_pressed():
	get_parent().end_scene()

func _on_p1_deck_preset_toggled(toggled_on):
	load_decks($P1/Deck, toggled_on)
	refresh()

func _on_deck_item_selected(index):
	refresh()
