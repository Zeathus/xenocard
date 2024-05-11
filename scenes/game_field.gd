extends Node2D

class_name GameField

signal zone_selected(field: GameField, zone_owner: Player, zone: Enum.Zone, index: int)

var player: Player
var game_board: GameBoard
var standby: Array[Card]
var battlefield: Array[Card]
var situation: Array[Card]
var zones: Dictionary

func _ready():
	standby = [null, null, null, null]
	battlefield = [null, null, null, null]
	situation = [null, null, null, null]
	zones = {
		Enum.Zone.STANDBY: [
			$Standby/Zone1, $Standby/Zone2,
			$Standby/Zone3, $Standby/Zone4
		],
		Enum.Zone.BATTLEFIELD: [
			$Battlefield/Zone1, $Battlefield/Zone2,
			$Battlefield/Zone3, $Battlefield/Zone4
		],
		Enum.Zone.SITUATION: [
			$Situation/Zone1, $Situation/Zone2,
			$Situation/Zone3, $Situation/Zone4
		]
	}
	if global_rotation != 0:
		for i in [$Deck/Count, $Lost/Count, $Junk/Count, $Deck/Label, $Lost/Label, $Junk/Label]:
			i.rotation = -global_rotation

func standby_count():
	var count: int = 0
	for i in standby:
		if i != null:
			count += 1
	return count

func battlefield_count():
	var count: int = 0
	for i in battlefield:
		if i != null:
			count += 1
	return count

func situation_count():
	var count: int = 0
	for i in situation:
		if i != null:
			count += 1
	return count

func battler_count():
	return standby_count() + battlefield_count()

func get_standby_cards() -> Array[Card]:
	var cards: Array[Card] = []
	for i in standby:
		if i != null:
			cards.push_back(i)
	return cards

func get_battlefield_cards() -> Array[Card]:
	var cards: Array[Card] = []
	for i in battlefield:
		if i != null:
			cards.push_back(i)
	return cards

func get_situation_cards() -> Array[Card]:
	var cards: Array[Card] = []
	for i in situation:
		if i != null:
			cards.push_back(i)
	return cards

func get_battler_cards() -> Array[Card]:
	return get_standby_cards() + get_battlefield_cards()

func get_all_cards() -> Array[Card]:
	return get_standby_cards() + get_battlefield_cards() + get_situation_cards()

func remove_card(card: Card):
	card.reset()
	$Cards.remove_child(card.instance)
	if get_card(card.zone, card.zone_index) == card:
		set_card(null, card.zone, card.zone_index)

func set_card(card: Card, zone: Enum.Zone, index: int):
	add_card(card)
	match zone:
		Enum.Zone.STANDBY:
			standby[index] = card
		Enum.Zone.BATTLEFIELD:
			battlefield[index] = card
		Enum.Zone.SITUATION:
			situation[index] = card
	if card != null:
		card.zone = zone
		card.zone_index = index
	refresh()

func add_card(card: Card):
	if card != null and card.zone in [Enum.Zone.HAND, Enum.Zone.DECK, Enum.Zone.LOST, Enum.Zone.JUNK]:
		var pos = card.instance.global_position
		$Cards.add_child(card.instance)
		card.instance.global_position = pos
		card.instance.turn_up()

func move_card(card: Card, zone: Enum.Zone, index: int):
	var old_card: Card = get_card(zone, index)
	set_card(old_card, card.zone, card.zone_index)
	set_card(card, zone, index)

func get_card(zone: Enum.Zone, index: int) -> Card:
	match zone:
		Enum.Zone.STANDBY:
			return standby[index]
		Enum.Zone.BATTLEFIELD:
			return battlefield[index]
		Enum.Zone.SITUATION:
			return situation[index]
	return null

func set_player(player: Player):
	self.player = player
	refresh()

func get_zone(type: Enum.Zone, index: int):
	if type in zones:
		return zones[type][index]
	return null

func show_valid_targets(card: Card):
	var filter = card.targets_to_select()[len(game_board.targeted_cards)]
	for zone in [Enum.Zone.STANDBY, Enum.Zone.BATTLEFIELD, Enum.Zone.SITUATION]:
		for index in range(4):
			var border = get_zone(zone, index).find_child("SelectBorder")
			var candidate = get_card(zone, index)
			border.visible = candidate and filter.call(candidate)

func show_valid_effect_targets(effect: CardEffect, filter: CardFilter):
	for zone in [Enum.Zone.STANDBY, Enum.Zone.BATTLEFIELD, Enum.Zone.SITUATION]:
		for index in range(4):
			var border = get_zone(zone, index).find_child("SelectBorder")
			var candidate = get_card(zone, index)
			border.visible = candidate and filter.is_valid(effect.card.owner, candidate)

func show_valid_set_targets(filter: Callable):
	for zone in [Enum.Zone.STANDBY, Enum.Zone.BATTLEFIELD, Enum.Zone.SITUATION]:
		for index in range(4):
			var border = get_zone(zone, index).find_child("SelectBorder")
			var candidate = get_card(zone, index)
			border.visible = candidate and filter.call(candidate)

func show_valid_zones(card: Card):
	for zone in [Enum.Zone.STANDBY, Enum.Zone.BATTLEFIELD, Enum.Zone.SITUATION]:
		for index in range(4):
			var border = get_zone(zone, index).find_child("SelectBorder")
			if game_board.turn_phase == Enum.Phase.SET:
				border.visible = card.can_play(game_board, zone, index)
			elif game_board.turn_phase == Enum.Phase.MOVE:
				border.visible = card.can_move_to(game_board, zone, index)

func hide_valid_zones():
	for zone in [Enum.Zone.STANDBY, Enum.Zone.BATTLEFIELD, Enum.Zone.SITUATION]:
		for index in range(4):
			var border = get_zone(zone, index).find_child("SelectBorder")
			border.visible = false

func get_deck_node() -> Node2D:
	return $Deck

func get_lost_node() -> Node2D:
	return $Lost

func get_junk_node() -> Node2D:
	return $Junk

func refresh():
	$Deck/Count.text = "%d" % player.deck.size()
	$Lost/Count.text = "%d" % player.lost.size()
	$Junk/Count.text = "%d" % player.junk.size()
	$Lost/Card.visible = player.lost.size() > 0
	$Junk/Card.visible = player.junk.size() > 0
	if player.junk.size() > 0:
		var top_junk: Card = player.junk.top()
		$Junk/Card.load_card(top_junk)
		$Junk/Card.turn_up()
	for zone_type in [Enum.Zone.STANDBY, Enum.Zone.BATTLEFIELD]:
		for i in range(4):
			var card: Card = get_card(zone_type, i)
			var status = get_zone(zone_type, i).find_child("CardStatus")
			status.show_card(card)

func _on_zone_selected(zone, index):
	zone_selected.emit(self, player, zone, index)

func _on_junk_input_event(viewport, event, shape_idx):
	if not game_board.is_free():
		return
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == 1 or event.button_index == 2:
				var tscn = load("res://scenes/menu_browse_cards.tscn")
				var scene = tscn.instantiate()
				scene.set_message("Viewing Junk Pile")
				scene.set_cards(player.junk.cards)
				game_board.add_menu(scene, 1)
				game_board.free_menu = scene
