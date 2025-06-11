extends Node2D

class_name GameBoard

signal game_ended

var quick_details_enabled: bool = true
var quick_detail_card: Card = null
var quick_detail_card_timer: float = 0

var game_id: int = randi()
var players: Array[Player]
var turn_player_id: int = 0
var turn_phase: Enum.Phase = Enum.Phase.DRAW
var card_zones: Array[Node2D]
var event_queue: Array[Event]
var free_menu = null
var phase_effects: Dictionary
var player_options: Array[Dictionary] = []
var game_options: Dictionary = {}
var countering_player: Player = null
var turn_count: int = 0
var online_mode: int = 0
var client: TCGClient = null
var server: TCGServer = null
var dummy_card: Card = Card.new("SYS/anon")
var tutorial: Tutorial = null

# Called when the node enters the scene tree for the first time.
func _ready():
	$MenuNode/MenuPanel/VolumeMusic.value = Options.music_volume
	$MenuNode/MenuPanel/VolumeSounds.value = Options.sounds_volume
	$MenuNode/MenuPanel/VolumeMusic/Mute.button_pressed = Options.music_mute
	$MenuNode/MenuPanel/VolumeSounds/Mute.button_pressed = Options.sounds_mute
	if server == null:
		get_parent().play_bgm("battle_xenosaga_1")
	$AnonCard.turn_down()
	for i in Enum.Phase:
		phase_effects[Enum.Phase[i]] = []
	card_zones = []
	for node in find_children("Zone?", "Node2D"):
		card_zones.push_back(node)
	if "tutorial" in game_options:
		tutorial = game_options["tutorial"]
	if "online" in game_options:
		if game_options["online"] == "client":
			online_mode = 1
			new_client_game()
		elif game_options["online"] == "server":
			online_mode = 2
			new_game()
	elif "load_game" in game_options:
		load_game(game_options["load_game"])
	else:
		new_game()

func new_game():
	for i in range(2):
		var options: Dictionary = player_options[i]
		var deck: Deck
		if "cards" in options["deck"]:
			deck = Deck.from_cards(options["deck"]["cards"])
		else:
			deck = Deck.load(options["deck"]["name"], options["deck"]["preset"])
		var player: Player = Player.new(
			i,
			deck,
			[$FieldPlayer, $FieldEnemy][i],
			[$HandPlayer, $HandEnemy][i],
			self
		)
		if online_mode == 2: # Server
			player.controller = ControllerServer.new(self, player, server, options["peer"])
			add_child(player.controller)
			player.controller.start()
			player.show_hand = true
		else:
			if options["ai"]:
				player.controller = ControllerAI.new(self, player)
				add_child(player.controller)
				player.controller.start()
			player.show_hand = (not player.has_controller()) or game_options["reveal_hands"]
		players.push_back(player)
	turn_player_id = randi_range(0, 1)
	queue_event(EventFlipCoin.new(self, turn_player_id == 0))
	for i in range(5):
		queue_event(EventDrawCard.new(self, players[turn_player_id]))
	for i in range(5):
		queue_event(EventDrawCard.new(self, players[(turn_player_id + 1) % 2]))
	begin_turn()

func new_client_game():
	for i in range(2):
		var deck: Deck = Deck.new_anonymous(40)
		var player: Player = Player.new(
			i,
			deck,
			[$FieldPlayer, $FieldEnemy][i],
			[$HandPlayer, $HandEnemy][i],
			self
		)
		if i == 0:
			player.show_hand = true
		else:
			player.show_hand = false
			player.controller = ControllerClient.new(self, player, client)
			add_child(player.controller)
			player.controller.start()
		players.push_back(player)
	turn_player_id = 0
	refresh()
	queue_event(EventOnlineClient.new(self, client))

func load_game(path: String):
	var data: Dictionary
	if "res://" in path:
		if FileAccess.file_exists(path):
			var file = FileAccess.open(path, FileAccess.READ)
			var json = JSON.new()
			var error = json.parse(file.get_as_text())
			if error == OK:
				data = json.data
			else:
				Logger.e("Failed to to parse game file '%s'" % path)
				return null
		else:
			Logger.e("Failed to find game file '%s'" % path)
			return null
	else:
		if ResourceLoader.exists(path):
			var file = load(path)
			var json = JSON.new()
			var error = json.parse(file.get_as_text())
			if error == OK:
				data = json.data
			else:
				Logger.e("Failed to to parse game file '%s'" % path)
				return null
		else:
			Logger.e("Failed to find game file '%s'" % path)
			return null
	turn_player_id = data["turn_player_id"]
	turn_phase = data["turn_phase"]
	turn_count = data["turn_count"]
	for i in range(2):
		var player: Player = Player.new(
			i,
			Deck.new(),
			[$FieldPlayer, $FieldEnemy][i],
			[$HandPlayer, $HandEnemy][i],
			self
		)
		players.push_back(player)
	for i in range(2):
		var player: Player = players[i]
		var player_data: Dictionary = data["players"][i]
		for id in player_data["deck"]:
			player.deck.cards.push_back(Card.new(id))
		for id in player_data["lost"]:
			player.lost.cards.push_back(Card.new(id))
		for id in player_data["junk"]:
			player.junk.cards.push_back(Card.new(id))
		player.deck.set_owner(player)
		player.lost.set_owner(player)
		player.junk.set_owner(player)
		for id in player_data["hand"]:
			var card: Card = Card.new(id)
			card.owner = player
			card.instantiate()
			prepare_card(card)
			player.hand.add_card(card)
		player.hand.refresh()
		for pos in range(4):
			var card = player_data["battlefield"][pos]
			if card != null:
				player.field.set_card(json_to_card(card, player), Enum.Zone.BATTLEFIELD, pos)
			card = player_data["standby"][pos]
			if card != null:
				player.field.set_card(json_to_card(card, player), Enum.Zone.STANDBY, pos)
			card = player_data["situation"][pos]
			if card != null:
				player.field.set_card(json_to_card(card, player), Enum.Zone.SITUATION, pos)
		for card in player.field.get_all_cards():
			card.instance.global_position = player.field.get_zone(card.zone, card.zone_index).global_position
			if card.equipped_weapon:
				player.field.add_card(card.equipped_weapon)
				card.equipped_weapon.instance.scale = Vector2(0.075, 0.075)
				card.equipped_weapon.instance.global_position = card.instance.global_position
				if card.instance.global_rotation == 0:
					card.equipped_weapon.instance.global_position += Vector2(28, 42)
				else:
					card.equipped_weapon.instance.global_position -= Vector2(28, 42)
		if player_data["ai"]:
			player.controller = ControllerAI.new(self, player)
			add_child(player.controller)
			player.controller.start()
		player.show_hand = (not player.has_controller()) or game_options["reveal_hands"]
	refresh()
	begin_phase(turn_phase)

func save_game(path: String):
	# This function does not save phase effects.
	# Only for internal use.
	DirAccess.make_dir_absolute(path.substr(0, path.rfind("/")))
	var game_file = FileAccess.open(path, FileAccess.WRITE)
	var json_data: Dictionary = {
		"turn_player_id": turn_player_id,
		"turn_phase": turn_phase,
		"turn_count": turn_count,
		"players": [
			field_to_json(players[0]),
			field_to_json(players[1])
		]
	}
	var json_string = JSON.stringify(json_data)
	game_file.store_line(json_string)

func field_to_json(player: Player) -> Dictionary:
	# This function does not save effects applied to players.
	var data: Dictionary = {
		"ai": player.has_controller(),
		"deck": [],
		"lost": [],
		"junk": [],
		"hand": [],
		"battlefield": [null, null, null, null],
		"standby": [null, null, null, null],
		"situation": [null, null, null, null],
	}
	for card in player.deck.cards:
		data["deck"].push_back("%s/%s" % [card.get_set_name(), card.get_id()])
	for card in player.lost.cards:
		data["lost"].push_back("%s/%s" % [card.get_set_name(), card.get_id()])
	for card in player.junk.cards:
		data["junk"].push_back("%s/%s" % [card.get_set_name(), card.get_id()])
	for card in player.hand.cards:
		data["hand"].push_back("%s/%s" % [card.get_set_name(), card.get_id()])
	for i in range(4):
		var card: Card = player.field.get_card(Enum.Zone.BATTLEFIELD, i)
		if card:
			data["battlefield"][i] = card_to_json(card)
		card = player.field.get_card(Enum.Zone.STANDBY, i)
		if card:
			data["standby"][i] = card_to_json(card)
		card = player.field.get_card(Enum.Zone.SITUATION, i)
		if card:
			data["situation"][i] = card_to_json(card)
	return data

func card_to_json(card: Card) -> Dictionary:
	# This function is not complete. It does not contains
	# effect information, such as duration or applied effects.
	# Right now it is only for internal use.
	var data: Dictionary = {
		"id": "%s/%s" % [card.get_set_name(), card.get_id()],
		"turn_count": card.turn_count
	}
	if card.hp != 0:
		data["hp"] = card.hp
	if card.downed:
		data["downed"] = true
		data["downed_turn"] = card.downed_turn
	if card.e_mark:
		data["e_mark"] = true
	if card.atk_timer != 0:
		data["atk_timer"] = card.atk_timer
	if card.equipped_weapon:
		data["weapon"] = card_to_json(card.equipped_weapon)
	return data

func json_to_card(data: Dictionary, owner: Player) -> Card:
	var card: Card = Card.new(data["id"])
	card.owner = owner
	card.instantiate()
	prepare_card(card)
	if "turn_count" in data:
		card.turn_count = data["turn_count"]
	if "hp" in data:
		card.hp = data["hp"]
	if "downed" in data:
		if data["downed"]:
			card.down(null)
			card.downed_turn = data["downed_turn"]
	if "e_mark" in data:
		card.set_e_mark(data["e_mark"])
	if "atk_timer" in data:
		card.atk_timer = data["atk_timer"]
	if "weapon" in data:
		card.equip(json_to_card(data["weapon"], owner))
	return card

func end_game(result: Enum.GameResult):
	for p in players:
		if p.has_controller():
			p.controller.stop()
	if not is_server():
		get_parent().last_game_result = result
	event_queue.clear()
	if is_client():
		event_queue.push_back(EventOnlineClient.new(self, client, EventEndGame.new(self, result)))
	else:
		event_queue.push_back(EventEndGame.new(self, result))

func end_scene():
	game_ended.emit()
	if is_server():
		server.end_board(self)
	else:
		get_parent().play_bgm("umn_mode")
		get_parent().end_scene()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $TestLabel.visible:
		var event_str: String = "Events: ["
		for e in event_queue:
			if e != event_queue.front():
				event_str += " "
			event_str += event_to_str(e)
		event_str += "]"
		$TestLabel.text = event_str
	
	if is_client() and client.game_result != Enum.GameResult.NONE:
		if can_end_game_on_current_event():
			end_game(client.game_result)
			client.game_result = Enum.GameResult.NONE
	
	var can_end_phase: bool = false
	if is_free() and not get_turn_player().has_controller() and event_processing():
		can_end_phase = event_queue.size() > 0 and event_queue.front().can_end_phase()
	$Phases/EndPhase.disabled = not can_end_phase
	
	if quick_detail_card:
		if quick_detail_card.is_hovered():
			quick_detail_card_timer = 0.25
		else:
			quick_detail_card_timer -= delta
			if quick_detail_card_timer <= 0:
				$QuickDetails/Left.visible = false
				$QuickDetails/Right.visible = false
				quick_detail_card = null
				for p in players:
					p.field.reset_attackable()
	
	if $CardDetails.visible:
		if Input.is_action_just_pressed("left_click"):
			$CardDetails.visible = false
	elif free_menu:
		if free_menu.is_done():
			$Menus.remove_child(free_menu)
			free_menu.finish()
			free_menu = null
	if event_processing():
		var event = get_event()
		event.process(delta)
		if event.is_done():
			event_queue.pop_front()
		return

func add_menu(menu, _z_index=0):
	menu.z_index = _z_index
	$Menus.add_child(menu)

func remove_menu(menu):
	$Menus.remove_child(menu)
	menu.queue_free()

func event_to_str(event: Event) -> String:
	var ret: String = event.get_name()
	if event.has_children():
		ret += ">["
		for e in event.children:
			if e != event.children.front():
				ret += " "
			ret += event_to_str(e)
		ret += "]"
	return ret

func event_processing() -> bool:
	return len(event_queue) > 0

func get_event() -> Event:
	return event_queue.front()

func queue_event(event: Event):
	if event.broadcasted and is_client():
		return
		#event_queue.push_back(EventOnlineClient.new(self, client, event.get_name()))
	else:
		if is_tutorial():
			var hint: TutorialHint = tutorial.get_hint(turn_count, event)
			if hint != null:
				if hint.type == 0:
					event = EventHint.new(self, event, hint.text, hint.pos)
					hint.exec.call(self)
				elif hint.type == 1:
					var on_confirm: Callable = func():
						hint.exec.call(self)
					var confirm_event = EventConfirm.new(self, players[0], "Tutorial", on_confirm, on_confirm, hint.text)
					confirm_event.set_yes_only()
					confirm_event.set_timeout(0)
					event_queue.push_back(confirm_event)
		event_queue.push_back(event)

func queue_next_event(event: Event):
	event_queue.insert(1, event)

func is_free() -> bool:
	return free_menu == null and not $CardDetails.visible

func skips_phase(phase: Enum.Phase, player: Player):
	for card in get_all_field_cards():
		for e in card.get_effects(Enum.Trigger.PASSIVE):
			if e.skips_phase(phase, player):
				return true
	for effect in player.applied_effects:
		if effect.skips_phase(phase, player):
			return true
	return false

func begin_phase(phase: Enum.Phase):
	turn_phase = phase
	var player: Player = get_turn_player()
	match turn_phase:
		Enum.Phase.DRAW:
			queue_event(EventPhaseDraw.new(self, player, phase_effects[Enum.Phase.DRAW]))
		Enum.Phase.MOVE:
			queue_event(EventPhaseMove.new(self, player, phase_effects[Enum.Phase.MOVE]))
		Enum.Phase.EVENT:
			queue_event(EventPhaseEventBlock.new(self, player, phase_effects[Enum.Phase.EVENT], false))
		Enum.Phase.SET:
			queue_event(EventPhaseSet.new(self, player, phase_effects[Enum.Phase.SET]))
		Enum.Phase.BLOCK:
			queue_event(EventPhaseEventBlock.new(self, player, phase_effects[Enum.Phase.BLOCK], true))
		Enum.Phase.BATTLE:
			queue_event(EventPhaseBattle.new(self, player, phase_effects[Enum.Phase.BATTLE]))
		Enum.Phase.ADJUST:
			queue_event(EventPhaseAdjust.new(self, player, phase_effects[Enum.Phase.ADJUST]))

func end_phase():
	match turn_phase:
		Enum.Phase.DRAW:
			begin_phase(Enum.Phase.MOVE)
		Enum.Phase.MOVE:
			begin_phase(Enum.Phase.EVENT)
		Enum.Phase.EVENT:
			begin_phase(Enum.Phase.SET)
		Enum.Phase.SET:
			begin_phase(Enum.Phase.BLOCK)
		Enum.Phase.BLOCK:
			begin_phase(Enum.Phase.BATTLE)
		Enum.Phase.BATTLE:
			begin_phase(Enum.Phase.ADJUST)
		Enum.Phase.ADJUST:
			next_player()
			begin_turn()
	refresh()

func begin_turn():
	queue_event(EventStartTurn.new(self, get_turn_player()))
	begin_phase(Enum.Phase.DRAW)

func refresh():
	for player: Player in [get_turn_player(), get_turn_enemy()]:
		player.field.refresh()
		var old_reveal_hand: bool = player.reveal_hand
		player.set_reveal_hand(false)
		for card in get_all_field_cards():
			for e in card.get_effects(Enum.Trigger.PASSIVE):
				var reveal_hand = e.reveal_hand(player)
				if reveal_hand:
					player.set_reveal_hand(reveal_hand)
			var duration = 0
			for e in card.effects:
				if e.duration > 0:
					duration = e.duration
					break
			card.instance.set_duration(duration)

func next_player():
	turn_player_id = (turn_player_id + 1) % 2

func prepare_card(card: Card) -> Card:
	card.reset()
	card.instance.show_details.connect(_on_card_show_details)
	card.instance.on_hover.connect(_on_card_hovered)
	return card

func get_turn_player() -> Player:
	var player_id: int = turn_player_id
	if turn_phase == Enum.Phase.BLOCK:
		player_id = (player_id + 1) % 2
	return players[player_id]

func get_turn_enemy() -> Player:
	return get_turn_player().get_enemy()

func hide_valid_zones():
	get_turn_player().field.hide_valid_zones()
	get_turn_enemy().field.hide_valid_zones()

func get_all_field_cards() -> Array[Card]:
	var result: Array[Card] = []
	result += get_turn_player().field.get_all_cards()
	result += get_turn_enemy().field.get_all_cards()
	return result

func get_all_battlefield_cards() -> Array[Card]:
	var result: Array[Card] = []
	result += get_turn_player().field.get_battlefield_cards()
	result += get_turn_enemy().field.get_battlefield_cards()
	return result

func add_phase_effect(phase: Enum.Phase, effect: Effect):
	phase_effects[phase].push_back(effect)

func play_se(se: String, db: float = 0, pitch: float = 1):
	var sound = null
	if ResourceLoader.exists("res://audio/se/" + se + ".wav"):
		sound = load("res://audio/se/" + se + ".wav")
	elif ResourceLoader.exists("res://audio/se/" + se + ".ogg"):
		sound = load("res://audio/se/" + se + ".ogg")
	if sound == null:
		Logger.w("Failed to find se '%s'" % se)
		return
	for player: AudioStreamPlayer2D in [$AudioStream1, $AudioStream2, $AudioStream3]:
		if not player.is_playing():
			player.volume_db = db
			player.pitch_scale = pitch
			player.stream = sound
			player.play()
			break

func play_animation(animation: String) -> void:
	$AnimationPlayer.play(animation)

func get_card_from_online_id(online_id: String, inverse: bool = false) -> Card:
	var args: PackedStringArray = online_id.split(",")
	var player_id: int = int(args[0])
	if player_id != 0 and player_id != 1:
		Logger.e("Invalid player id: " % online_id)
		return null
	if inverse:
		player_id = (player_id + 1) % 2
	var zone: Enum.Zone = Enum.Zone.NONE
	match args[1]:
		"H":
			zone = Enum.Zone.HAND
		"D":
			zone = Enum.Zone.DECK
		"L":
			zone = Enum.Zone.LOST
		"J":
			zone = Enum.Zone.JUNK
		"W": # W for "Waiting" to avoid collision with Situation
			zone = Enum.Zone.STANDBY
		"B":
			zone = Enum.Zone.BATTLEFIELD
		"S":
			zone = Enum.Zone.SITUATION
		_:
			Logger.e("Invalid zone: " + online_id)
			return null
	if zone == Enum.Zone.HAND:
		var index: int = int(args[2])
		if index < 0 or index > len(players[player_id].hand.cards):
			Logger.e("Invalid hand index: " + online_id)
			return null
		return players[player_id].hand.cards[index]
	if zone in [Enum.Zone.DECK, Enum.Zone.LOST, Enum.Zone.JUNK]:
		var card_list: Array[Card] = []
		match zone:
			Enum.Zone.HAND:
				card_list = players[player_id].hand.cards
			Enum.Zone.DECK:
				card_list = players[player_id].deck.cards
			Enum.Zone.LOST:
				card_list = players[player_id].lost.cards
			Enum.Zone.JUNK:
				card_list = players[player_id].junk.cards
		for card in card_list:
			if card.data.get_full_id() == args[2]:
				return card
	else:
		var zone_index: int = int(args[2])
		if zone_index < 0 or zone_index > 7:
			Logger.e("Invalid zone index: " + online_id)
			return null
		var card: Card = players[player_id].field.get_card(zone, zone_index % 4)
		if zone_index > 3:
			card = card.equipped_weapon
		return card
	Logger.e("Failed to find card: " + online_id)
	return null

func is_client() -> bool:
	return online_mode == 1

func is_server() -> bool:
	return online_mode == 2

func is_tutorial() -> bool:
	return tutorial != null

func show_details(card):
	$CardDetails.visible = true
	$CardDetails/CardNode.turn_up()
	$CardDetails/CardNode.show_card(card.data)

func can_end_game_on_current_event():
	if event_queue.is_empty():
		return true
	var event: Event = event_queue.front()
	while event.children.size() > 0:
		event = event.children.front()
	return event.stop_on_game_end()

func get_hint_node() -> HintNode:
	return $HintNode

func _on_card_show_details(card):
	if card.instance and card.instance.is_face_down():
		return
	show_details(card)

func _on_card_hovered(card):
	$QuickDetails/Left.visible = false
	$QuickDetails/Right.visible = false
	if card.instance and card.instance.is_face_down():
		return
	var display = $QuickDetails/Left
	var display_card = $QuickDetails/Left/CardNode
	if (card.owner == players[0] and card.zone == Enum.Zone.STANDBY) or \
		(card.owner == players[1] and card.zone == Enum.Zone.SITUATION):
		display = $QuickDetails/Right
		display_card = $QuickDetails/Right/CardNode
	display.visible = true
	display_card.turn_up()
	display_card.show_card(card.data)
	quick_detail_card = card
	for p in players:
		p.field.reset_attackable()
	if card.zone == Enum.Zone.BATTLEFIELD:
		var targets = card.get_attack_targets(self)
		for t in targets:
			if t.is_player():
				t.field.get_deck_node().find_child("Attackable").visible = true
			else:
				var zone: Node2D = t.owner.field.get_zone(t.zone, t.zone_index)
				zone.find_child("Attackable").visible = true

func on_hand_card_selected(hand: GameHand, card: Card):
	if not is_free():
		return
	if event_processing():
		get_event().on_hand_card_selected(hand, card)

func _on_zone_selected(field: GameField, zone_owner: Player, zone: Enum.Zone, index: int):
	if not is_free():
		return
	if event_processing():
		get_event().on_zone_selected(field, zone_owner, zone, index)

func _on_end_phase_pressed():
	if not is_free():
		return
	if get_turn_player().has_controller():
		return
	if event_processing():
		get_event().on_end_phase_pressed()

func _on_test_button_pressed():
	save_game("res://tutorial/saved_games/test.json")

func _on_button_menu_pressed() -> void:
	$ButtonMenu.disabled = true
	$MenuNode.visible = true

func _on_forfeit_button_pressed() -> void:
	$MenuNode.visible = false
	if is_client():
		players[1].controller.send_action(Controller.Action.FORFEIT)
	else:
		end_game(Enum.GameResult.CANCELLED)

func _on_close_menu_button_pressed() -> void:
	$ButtonMenu.disabled = false
	$MenuNode.visible = false
	Options.save()

func _on_phase_hitbox_mouse_entered() -> void:
	$Phases/AllPhases.visible = true
	$Phases/AllPhases/Header.text = "P%d TURN" % (turn_player_id + 1)
	var all_phases: Array[Label] = [
		$Phases/AllPhases/Draw,
		$Phases/AllPhases/Move,
		$Phases/AllPhases/Event,
		$Phases/AllPhases/Set,
		$Phases/AllPhases/Block,
		$Phases/AllPhases/Battle,
		$Phases/AllPhases/Adjust,
	]
	var phase_names: Array[String] = [
		"Draw",
		"Move",
		"Event",
		"Set",
		"Block",
		"Battle",
		"Adjust",
	]
	for i in range(all_phases.size()):
		if i == 4:
			if ((turn_player_id + 1) % 2) == 0:
				all_phases[i].text = "P1 %s Phase" % phase_names[i]
			else:
				all_phases[i].text = "%s Phase P2" % phase_names[i]
			all_phases[i].horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if turn_player_id == 0 else HORIZONTAL_ALIGNMENT_LEFT
		else:
			if turn_player_id == 0:
				all_phases[i].text = "P1 %s Phase" % phase_names[i]
			else:
				all_phases[i].text = "%s Phase P2" % phase_names[i]
			all_phases[i].horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT if turn_player_id == 0 else HORIZONTAL_ALIGNMENT_RIGHT

func _on_phase_hitbox_mouse_exited() -> void:
	$Phases/AllPhases.visible = false

func _on_volume_music_value_changed(value: float) -> void:
	$MenuNode/MenuPanel/VolumeMusic/Value.text = "%d%%" % value
	Options.set_music_volume(value)

func _on_volume_sounds_value_changed(value: float) -> void:
	$MenuNode/MenuPanel/VolumeSounds/Value.text = "%d%%" % value
	Options.set_sounds_volume(value)

func _on_music_mute_toggled(toggled_on: bool) -> void:
	Options.set_music_mute(toggled_on)

func _on_sounds_mute_toggled(toggled_on: bool) -> void:
	Options.set_sounds_mute(toggled_on)
