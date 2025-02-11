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
	load_decks($RoomMenu/Deck, $RoomMenu/DeckPreset.button_pressed)
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
				if last_state == TCGClient.ClientState.AWAIT_HOST:
					set_host_menu_disabled(false)
					$HostPrompt/FailedLabel.visible = true
				elif client.rooms.size() == 0:
					connection_status.visible = true
					connection_status.text = "No rooms found. Try hosting one!"
				else:
					connection_status.visible = false
					refresh_room_list()
			TCGClient.ClientState.IN_ROOM:
				$HostPrompt.visible = false
				$ClickBlock.visible = true
				$RoomMenu.visible = true
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
		client.send_deck(Deck.load(get_deck(), $RoomMenu/DeckPreset.button_pressed))
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
	client.room_updated.connect(on_room_update)

func on_join_pressed(room: ServerRoom):
	$ClickBlock.visible = true
	client.join_room(room.id)

func on_room_update():
	$RoomMenu/Header.text = client.current_room.name
	$RoomMenu/P1Name.text = client.current_room.p1_name if client.current_room.p1_name != "" else "<None>"
	$RoomMenu/P2Name.text = client.current_room.p2_name if client.current_room.p2_name != "" else "<None>"

func refresh_room_list():
	var container: VBoxContainer = $ListPanel/ScrollContainer/VBoxContainer
	while container.get_child_count() > 0:
		var child = container.get_child(0)
		child.join.disconnect(on_join_pressed)
		container.remove_child(child)
	var y_pos: int = 0
	for room in client.rooms:
		var row: Node2D = row_scene.instantiate()
		row.set_room(room)
		row.position.x = 10
		row.position.y = y_pos
		row.join.connect(on_join_pressed)
		y_pos += 70
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
	var node: OptionButton = $RoomMenu/Deck
	return node.get_item_text(node.get_selected_id())

func set_host_menu_disabled(val: bool):
	$HostPrompt/RoomName.editable = not val
	$HostPrompt/Password.editable = not val
	$HostPrompt/AllowedCards.disabled = val
	$HostPrompt/HostButton.disabled = val
	$HostPrompt/HostExit.disabled = val
	$HostPrompt/FailedLabel.visible = false

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
	load_decks($RoomMenu/Deck, toggled_on)
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

func _on_room_name_text_changed(new_text: String) -> void:
	var base_name: String = $HostPrompt/RoomName.text
	var regex: RegEx = RegEx.new()
	regex.compile("[^A-Z^a-z^0-9^ ]")
	var room_name: String = regex.sub(base_name, "", true)
	if len(room_name) > 15 or base_name != room_name:
		room_name = room_name.substr(0, min(len(room_name), 15))
		var old_column: int = $HostPrompt/RoomName.get_caret_column()
		$HostPrompt/RoomName.text = room_name
		$HostPrompt/RoomName.set_caret_column(min(len(room_name), 15, old_column))
	$HostPrompt/HostButton.disabled = (len(room_name) > 0 and len(room_name) < 3) or len(room_name) > 15

func _on_password_text_changed(new_text: String) -> void:
	var base_password: String = $HostPrompt/Password.text
	var regex: RegEx = RegEx.new()
	regex.compile("[^A-Z^a-z^0-9]")
	var password: String = regex.sub(base_password, "", true)
	if len(password) > 15 or base_password != password:
		password = password.substr(0, min(len(password), 15))
		var old_column: int = $HostPrompt/Password.get_caret_column()
		$HostPrompt/Password.text = password
		$HostPrompt/Password.set_caret_column(min(len(password), 15, old_column))

func _on_show_password_toggled(toggled_on: bool) -> void:
	$HostPrompt/Password.secret = not toggled_on

func _on_host_exit_pressed() -> void:
	$ClickBlock.visible = false
	$HostPrompt.visible = false

func _on_host_button_pressed() -> void:
	var room_name = $HostPrompt/RoomName.text
	if len(room_name) < 3:
		room_name = $HostPrompt/RoomName.placeholder_text
	client.host_room(
		room_name,
		$HostPrompt/Password.text,
		$HostPrompt/AllowedCards.get_selected_id()
	)
	set_host_menu_disabled(true)

func _on_button_host_pressed() -> void:
	$ClickBlock.visible = true
	$HostPrompt.visible = true
	$HostPrompt/RoomName.text = ""
	$HostPrompt/Password.text = ""
	set_host_menu_disabled(false)

func _on_button_refresh_pressed() -> void:
	if client:
		client.state = TCGClient.ClientState.GET_ROOMS
		client.get_rooms()

func _on_leave_button_pressed() -> void:
	client.leave_room()
	$RoomMenu.visible = false
	$ClickBlock.visible = false
