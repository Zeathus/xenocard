extends Node2D

var card_scene = preload("res://objects/card.tscn")
var cards: Array[Card]
var filter: CardFilter = null
var use_filter: bool = true
var card_nodes: Array[Node2D]
var done: bool = false
var handler = null
var selected_index: int = -1
var selected_card: Card = null

func set_handler(val: Callable):
	$CloseButton.text = "Cancel"
	handler = val

func set_message(val: String):
	$HeaderPanel/Label.text = val

func set_forced(val: bool):
	$CloseButton.visible = val

func set_filter(filter: CardFilter):
	$UseFilter.visible = filter != null
	self.filter = filter

func set_cards(cards: Array[Card]):
	self.cards = cards
	for card in cards:
		var scene = card_scene.instantiate()
		scene.position.y = 125
		scene.scale = Vector2(0.15, 0.15)
		scene.load_card(card)
		scene.turn_up()
		scene.selected.connect(select_card)
		$Panel/ScrollCards/HBox.add_child(scene)
		card_nodes.push_back(scene)
	refresh_cards()

func refresh_cards():
	var pos_x: int = $Panel/ScrollCards.size.x / 2 - (len(cards) - 1) * 64
	if pos_x < 90:
		pos_x = 90
	var cards_found = 0
	for i in range(len(cards)):
		var card: Card = cards[i]
		var node: Node2D = card_nodes[i]
		if filter and use_filter:
			if not filter.is_valid(card.owner, card):
				node.visible = false
				continue
		node.visible = true
		node.position.x = pos_x
		pos_x += 128
		cards_found += 1
	var no_cards_label = $Panel/ScrollCards/HBox/NoCards
	if cards_found == 0:
		if len(cards) == 0:
			no_cards_label.text = "There are no cards here"
		else:
			no_cards_label.text = "No cards meet the criteria"
		no_cards_label.visible = true
	else:
		no_cards_label.visible = false
	if pos_x > $Panel/ScrollCards/HBox.custom_minimum_size.x:
		$Panel/ScrollCards/HBox.custom_minimum_size.x = pos_x - 40

func select_card(card: Card):
	if handler == null:
		return
	if filter and not filter.is_valid(card.owner, card):
		return
	for i in range(len(cards)):
		if card == cards[i]:
			selected_index = i
			selected_card = card
			break
	done = true

func _on_use_filter_toggled(toggled_on):
	use_filter = toggled_on
	refresh_cards()

func _on_close_button_pressed():
	done = true

func is_done():
	return done

func finish():
	if handler != null:
		handler.call(selected_index, selected_card)
	queue_free()
