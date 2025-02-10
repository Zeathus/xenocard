extends Node2D

var row_scene = load("res://scenes/online_row.tscn")
var game_scene = load("res://scenes/game_board.tscn")
var client: TCGClient = null
var connection_status: Label
var last_state: TCGClient.ClientState

# Called when the node enters the scene tree for the first time.
func _ready():
	connection_status = $ListPanel/ConnectingLabel
	if len(Options.username) < 3:
		$ClickBlock.visible = true
		$UsernamePrompt.visible = true
	else:
		connect_to_server()
	#load_decks($P1/Deck, $P1/DeckPreset.button_pressed)
	#refresh()
	#refresh_room_list()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if client == null or not client.connected():
		return
	if last_state != client.state:
		match client.state:
			TCGClient.ClientState.CONNECTING:
				client.send_username()
			TCGClient.ClientState.GET_ROOMS:
				connection_status.visible = true
				connection_status.text = "Fetching rooms..."
			TCGClient.ClientState.IN_LOBBY:
				if client.rooms.size() == 0:
					connection_status.visible = true
					connection_status.text = "No rooms found. Try hosting one!"
				else:
					connection_status.visible = false
					refresh_room_list()
			TCGClient.ClientState.STOPPED:
				match last_state:
					TCGClient.ClientState.SEND_NAME:
						connection_status.visible = true
						connection_status.text = "Invalid username. Change it in options."
						Options.username = ""
						Options.save()
				remove_child(client)
				client = null
				last_state = TCGClient.ClientState.NONE
				return
		last_state = client.state
	#if client.state == TCGClient.ClientState.CONNECTING:
	#	client.send_username()
	#elif false:
	#	connection_status.text = "Fetching rooms..."
	#	client.state = TCGClient.ClientState.GET_ROOMS
	elif client.state == TCGClient.ClientState.AWAIT_DECK:
		client.send_deck(Deck.load(get_deck(), $P1/DeckPreset.button_pressed))
	elif client.state == TCGClient.ClientState.START_GAME:
		client.state = TCGClient.ClientState.PLAYING
		var game = game_scene.instantiate()
		game.game_options["reveal_hands"] = false
		game.game_options["online"] = "client"
		game.client = client
		get_parent().start_scene(game)

func connect_to_server():
	connection_status.visible = true
	connection_status.text = "Connecting to server..."
	client = TCGClient.new()
	add_child(client)

func refresh_room_list():
	var container: VBoxContainer = $ListPanel/ScrollContainer/VBoxContainer
	while container.get_child_count() > 0:
		container.remove_child(container.get_child(0))
	var y_pos: int = 0
	for i in client.rooms:
		var row: Node2D = row_scene.instantiate()
		#row.set_tutorial(tutorial)
		#if tutorial == selected_tutorial:
		#	row.set_pressed(true)
		row.position.x = 10
		row.position.y = y_pos
		#row.connect("click_tutorial", _on_tutorial_selected)
		y_pos += 76
		container.add_child(row)

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

func _on_username_text_changed() -> void:
	var base_username: String = $UsernamePrompt/Username.text
	var regex: RegEx = RegEx.new()
	regex.compile("[^A-Z^a-z^0-9^_]")
	var username: String = regex.sub(base_username, "", true)
	if len(username) > 15 or base_username != username:
		username = username.substr(0, min(len(username), 15))
		var old_column: int = $UsernamePrompt/Username.get_caret_column()
		$UsernamePrompt/Username.text = username
		$UsernamePrompt/Username.set_caret_column(min(len(username), 15, old_column))
	$UsernamePrompt/ConfirmButton.disabled = len(username) < 3 or len(username) > 15

func _on_confirm_button_pressed() -> void:
	var username: String = $UsernamePrompt/Username.text
	if len(username) < 3 or len(username) > 15:
		return
	Options.username = username
	Options.save()
	$ClickBlock.visible = false
	$UsernamePrompt.visible = false
	connect_to_server()
