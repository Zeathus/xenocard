extends Node2D

var card_row_scene = preload("res://scenes/card_list_row.tscn")
var card_scene = preload("res://objects/card.tscn")

var all_cards: Array[Card]
var deck: Deck = Deck.new()

func load_cards():
	all_cards = []
	var dir = DirAccess.open("res://data/cards")
	if not dir:
		print("Failed to find card directory.")
		return
	dir.list_dir_begin()
	var set_name = dir.get_next()
	while set_name != "":
		if not dir.current_is_dir():
			set_name = dir.get_next()
			continue
		var sub_dir = DirAccess.open("res://data/cards/%s" % set_name)
		sub_dir.list_dir_begin()
		var card_file = sub_dir.get_next()
		while card_file != "":
			card_file = card_file.substr(0, card_file.find(".json"))
			var card = Card.new("%s/%s" % [set_name, card_file])
			card.validate_effects()
			all_cards.push_back(card)
			card_file = sub_dir.get_next()
		set_name = dir.get_next()
		sub_dir.list_dir_end()
	dir.list_dir_end()

func sort_card_list():
	all_cards.sort_custom(func sort_id(a, b):
		if a.set_id < b.set_id:
			return true
		return false
	)

func setup_card_list():
	var container: VBoxContainer = $List/ScrollContainer/VBoxContainer
	var y_pos = 0
	for card in all_cards:
		var row: CardListRow = card_row_scene.instantiate()
		row.set_card(card)
		row.position.y = y_pos
		row.row_hovered.connect(preview_card)
		row.add_card.connect(add_to_deck)
		y_pos += 134
		container.add_child(row)
	container.custom_minimum_size.y = y_pos

func refresh_card_list():
	var container: VBoxContainer = $List/ScrollContainer/VBoxContainer
	var y_pos = 0
	var matches = 0
	for row in container.get_children():
		var card: Card = row.get_card()
		var show = filter_card(card)
		row.visible = show
		row.position.y = y_pos
		if show:
			y_pos += 134
			matches += 1
	container.custom_minimum_size.y = y_pos
	$List/Results/Label.text = "%d Cards" % matches

func refresh_deck():
	var children = $Deck.get_children()
	for node in children:
		node.visible = false
		node.turn_down()
	var cards_per_row: int = 10
	var card_spacing: Vector2i = Vector2i(100, 148)
	if deck.size() > 40:
		var more_per_row = ceil((deck.size() - 40) / 4.0)
		cards_per_row += more_per_row
		card_spacing.x = 1000 / cards_per_row
	for i in range(deck.size()):
		var node = null
		if i < len(children):
			node = children[i]
			for con in node.show_details.get_connections():
				node.show_details.disconnect(con.callable)
		else:
			node = card_scene.instantiate()
			node.scale = Vector2(0.12, 0.12)
			node.on_hover.connect(preview_card)
			$Deck.add_child(node)
		node.show_details.connect(func remove(card: Card):
			remove_from_deck(i)
		)
		node.visible = true
		node.turn_up()
		node.z_index = i
		node.position.x = 64 + card_spacing.x * (i % cards_per_row)
		node.position.y = 88 + card_spacing.y * floor(i / cards_per_row)
		node.load_card(deck.cards[i])

func refresh_deck_list():
	$Meta/LoadDeck.clear()
	for i in Deck.list_decks():
		$Meta/LoadDeck.add_item(i)
	if deck.name != "":
		for i in range($Meta/LoadDeck.item_count):
			if $Meta/LoadDeck.get_item_text(i) == deck.name:
				$Meta/LoadDeck.select(i)
				break

func refresh_preset_list():
	$Meta/LoadPreset.clear()
	$Meta/LoadPreset.add_item("Load a Preset")
	for i in Deck.list_presets():
		$Meta/LoadPreset.add_item(i)

func filter_card(card: Card) -> bool:
	var filter_text: String = $Filters/Search.text.to_lower()
	var filter_type: Card.Type = Card.type_from_string(
		$Filters/Type.get_item_text($Filters/Type.get_selected_id()))
	var filter_cost: String = $Filters/Cost.text
	var filter_attribute: Card.Attribute = Card.attribute_from_string(
		$Filters/Attribute.get_item_text($Filters/Attribute.get_selected_id()))
	var filter_hp: String = $Filters/HP.text
	var filter_atk: String = $Filters/ATK.text
	var filter_atk_type: Card.Target = Card.attack_type_from_string(
		$Filters/AttackType.get_item_text($Filters/AttackType.get_selected_id()))
	if filter_text != "":
		if filter_text not in card.name.replace("\n", " ").to_lower() and filter_text not in card.text.to_lower():
			return false
	if filter_type != Card.Type.ANY and card.type != filter_type:
		return false
	if filter_type == Card.Type.BATTLE:
		if filter_attribute != Card.Attribute.ANY and card.attribute != filter_attribute:
			return false
		if filter_atk_type != Card.Target.ANY and card.target != filter_atk_type:
			return false
		if not filter_integer(card.max_hp, filter_hp):
			return false
		if not filter_integer(card.atk, filter_atk):
			return false
	if not filter_integer(card.cost, filter_cost):
		return false
	return true

func filter_integer(value: int, filter: String) -> bool:
	if filter == "":
		return true
	if filter.is_valid_int():
		if value != int(filter):
			return false
	elif "-" in filter:
		var param = filter.split("-")
		if len(param) == 2 and param[0].is_valid_int() and param[1].is_valid_int():
			if value < int(param[0]) or value > int(param[1]):
				return false
	elif "<=" in filter:
		var param = filter.split("<=")
		if len(param[0]) == 0 and param[1].is_valid_int():
			if not value <= int(param[1]):
				return false
		elif len(param[1]) == 0 and param[0].is_valid_int():
			if not int(param[0]) <= value:
				return false
	elif ">=" in filter:
		var param = filter.split(">=")
		if len(param[0]) == 0 and param[1].is_valid_int():
			if not value >= int(param[1]):
				return false
		elif len(param[1]) == 0 and param[0].is_valid_int():
			if not int(param[0]) >= value:
				return false
	elif "<" in filter:
		var param = filter.split("<")
		if len(param[0]) == 0 and param[1].is_valid_int():
			if not value < int(param[1]):
				return false
		elif len(param[1]) == 0 and param[0].is_valid_int():
			if not int(param[0]) < value:
				return false
	elif ">" in filter:
		var param = filter.split(">")
		if len(param[0]) == 0 and param[1].is_valid_int():
			if not value > int(param[1]):
				return false
		elif len(param[1]) == 0 and param[0].is_valid_int():
			if not int(param[0]) > value:
				return false
	return true

# Called when the node enters the scene tree for the first time.
func _ready():
	load_cards()
	sort_card_list()
	setup_card_list()
	refresh_card_list()
	refresh_deck_list()
	refresh_preset_list()
	$Meta/LoadDeck.select(-1)

func add_to_deck(card: Card):
	if deck.size() < 40:
		deck.add_bottom(card)
		refresh_deck()

func remove_from_deck(index: int):
	deck.remove_at(index)
	refresh_deck()

func load_deck(deck_name: String, preset: bool = false):
	deck = Deck.load(deck_name, preset)
	$Meta/DeckName.text = deck.name
	refresh_deck()

func preview_card(card: Card):
	$Preview/CardDetails/Card.load_card(card)
	$Preview/CardDetails/Card.turn_up()
	var preview_text: RichTextLabel = $Preview/Text
	preview_text.clear()
	preview_text.push_font_size(20)
	preview_text.push_underline()
	preview_text.append_text(card.name.replace("\n", " "))
	preview_text.pop()
	if card.character != "":
		preview_text.append_text("\nCharacter: %s" % card.character)
	else:
		preview_text.append_text("\n")
	preview_text.append_text("\nGame: %s" % card.game)
	preview_text.pop_all()

func _on_visible_cards_area_entered(area):
	var parent = area.get_parent()
	if is_instance_of(parent, CardListRow):
		parent.load_card()

func _on_visible_cards_area_exited(area):
	var parent = area.get_parent()
	if is_instance_of(parent, CardListRow):
		parent.unload_card()

func _on_filters_changed(new_text):
	refresh_card_list()

func _on_type_item_selected(index):
	var is_battle = $Filters/Type.get_item_text(index) == "Battle"
	$Filters/HP.editable = is_battle
	$Filters/ATK.editable = is_battle
	$Filters/Attribute.disabled = not is_battle
	$Filters/AttackType.disabled = not is_battle
	refresh_card_list()

func _on_attribute_item_selected(index):
	refresh_card_list()

func _on_attack_type_item_selected(index):
	refresh_card_list()

func _on_button_save_pressed():
	if len($Meta/DeckName.text) == 0:
		return
	deck.name = $Meta/DeckName.text
	deck.save()
	refresh_deck_list()

func _on_button_save_as_pressed():
	if len($Meta/DeckName.text) == 0:
		return
	deck.name = $Meta/DeckName.text
	deck.save()
	refresh_deck_list()

func _on_button_shuffle_pressed():
	deck.shuffle()
	refresh_deck()

func _on_button_sort_pressed():
	deck.sort()
	refresh_deck()

func _on_load_deck_item_selected(index):
	var deck_name: String = $Meta/LoadDeck.get_item_text(index)
	load_deck(deck_name)

func _on_load_preset_item_selected(index):
	var deck_name: String = $Meta/LoadPreset.get_item_text(index)
	if deck_name != "Load a Preset":
		$Meta/LoadDeck.select(-1)
		$Meta/LoadPreset.select(0)
		load_deck(deck_name, true)

func _on_button_new_pressed():
	deck = Deck.new()
	$Meta/DeckName.text = ""
	$Meta/LoadDeck.select(-1)
	refresh_deck()

func _on_button_exit_pressed():
	get_parent().end_scene()

func _on_button_open_deck_dir_pressed():
	OS.shell_open("%s/decks" % OS.get_user_data_dir())
