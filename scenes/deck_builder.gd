extends Node2D

var card_row_scene = load("res://scenes/card_list_row.tscn")
var card_scene = load("res://objects/card_display_baked.tscn")

var all_cards: Array[CardData]
var deck: DeckData = DeckData.new()

func load_cards():
	all_cards = []
	for key in CardData.data:
		var data: CardData = CardData.data[key]
		if data.set_name != "SYS":
			all_cards.push_back(CardData.data[key])

func sort_card_list():
	var filters: Array[Callable] = []
	for filter_id in [$List/Sorting1.get_selected_id(), $List/Sorting2.get_selected_id()]:
		match filter_id:
			0: # Nothing
				pass
			1: # Name ASC
				filters.push_back(func sort(a: CardData, b: CardData):
					if a.get_name() < b.get_name():
						return 1
					elif a.get_name() > b.get_name():
						return -1
					return 0
				)
			2: # Name DSC
				filters.push_back(func sort(a: CardData, b: CardData):
					if a.get_name() < b.get_name():
						return -1
					elif a.get_name() > b.get_name():
						return 1
					return 0
				)
			3: # Attribute ASC
				filters.push_back(func sort(a: CardData, b: CardData):
					if a.attribute < b.attribute:
						return 1
					elif a.attribute > b.attribute:
						return -1
					return 0
				)
			4: # Attribute DSC
				filters.push_back(func sort(a: CardData, b: CardData):
					if a.attribute < b.attribute:
						return -1
					elif a.attribute > b.attribute:
						return 1
					return 0
				)
			5: # Attack Type ASC
				filters.push_back(func sort(a: CardData, b: CardData):
					if a.attack_type < b.attack_type:
						return 1
					elif a.attack_type > b.attack_type:
						return -1
					return 0
				)
			6: # Attack Type DSC
				filters.push_back(func sort(a: CardData, b: CardData):
					if a.attack_type < b.attack_type:
						return -1
					elif a.attack_type > b.attack_type:
						return 1
					return 0
				)
			7: # Cost ASC
				filters.push_back(func sort(a: CardData, b: CardData):
					if a.cost < b.cost:
						return 1
					elif a.cost > b.cost:
						return -1
					return 0
				)
			8: # Cost DSC
				filters.push_back(func sort(a: CardData, b: CardData):
					if a.cost < b.cost:
						return -1
					elif a.cost > b.cost:
						return 1
					return 0
				)
			9: # HP ASC
				filters.push_back(func sort(a: CardData, b: CardData):
					if a.max_hp < b.max_hp:
						return 1
					elif a.max_hp > b.max_hp:
						return -1
					return 0
				)
			10: # HP DSC
				filters.push_back(func sort(a: CardData, b: CardData):
					if a.max_hp < b.max_hp:
						return -1
					elif a.max_hp > b.max_hp:
						return 1
					return 0
				)
			11: # ATK ASC
				filters.push_back(func sort(a: CardData, b: CardData):
					if a.atk < b.atk:
						return 1
					elif a.atk > b.atk:
						return -1
					return 0
				)
			12: # ATK DSC
				filters.push_back(func sort(a: CardData, b: CardData):
					if a.atk < b.atk:
						return -1
					elif a.atk > b.atk:
						return 1
					return 0
				)
	all_cards.sort_custom(func sort(a: CardData, b: CardData):
		for filter in filters:
			var res: int = filter.call(a, b)
			if res == 1:
				return true
			elif res == -1:
				return false
		if a.set_number < b.set_number:
			return true
		elif a.set_number > b.set_number:
			return false
		if a.set_id < b.set_id:
			return true
		return false
	)

func setup_card_list():
	var container: VBoxContainer = $List/ScrollContainer/VBoxContainer
	var y_pos = 0
	var index = 0
	for card in all_cards:
		var row: CardListRow = card_row_scene.instantiate()
		row.set_index(index)
		row.position.y = y_pos
		row.row_hovered.connect(preview_card)
		row.add_card.connect(add_to_deck)
		y_pos += 134
		container.add_child(row)
		index += 1
	container.custom_minimum_size.y = y_pos

func refresh_card_list():
	var container: VBoxContainer = $List/ScrollContainer/VBoxContainer
	var y_pos = 0
	var matches = 0
	var index = 0
	var regex: RegEx = null
	if $Filters/SearchRegex.button_pressed:
		regex = RegEx.new()
		regex.compile($Filters/Search.text.to_lower())
		if not regex.is_valid():
			regex = null
	for row in container.get_children():
		var card: CardData = all_cards[index]
		var show_card = filter_card(card, regex)
		if row.loaded:
			row.set_card(card)
			row.loaded = false
			row.load_card()
		row.visible = show_card
		row.position.y = y_pos
		if show_card:
			y_pos += 134
			matches += 1
		index += 1
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
			for con in node.selected.get_connections():
				node.selected.disconnect(con.callable)
		else:
			node = card_scene.instantiate()
			node.scale = Vector2(0.12, 0.12)
			node.on_hover.connect(func preview(): preview_card(-1, deck.cards[i]))
			$Deck.add_child(node)
		node.selected.connect(func remove(button_index: int):
			if button_index == 2:
				remove_from_deck(i)
		)
		node.visible = true
		node.turn_up()
		node.z_index = i
		node.position.x = 64 + card_spacing.x * (i % cards_per_row)
		node.position.y = 88 + card_spacing.y * floor(i / cards_per_row)
		node.show_card(deck.cards[i])
	refresh_stats()

func refresh_stats():
	var attributes: Array[Enum.Attribute] = [
		Enum.Attribute.ANY,
		Enum.Attribute.HUMAN,
		Enum.Attribute.REALIAN,
		Enum.Attribute.MACHINE,
		Enum.Attribute.GNOSIS,
		Enum.Attribute.MONSTER,
		Enum.Attribute.NOPON,
		Enum.Attribute.BLADE,
		Enum.Attribute.UNKNOWN,
		Enum.Attribute.WEAPON
	]
	var attribute_nodes: Array[Node2D] = [
		$Stats/Any,
		$Stats/Human,
		$Stats/Realian,
		$Stats/Machine,
		$Stats/Gnosis,
		$Stats/Monster,
		$Stats/Nopon,
		$Stats/Blade,
		$Stats/Unknown,
		$Stats/Weapon
	]
	for i in range(0, attributes.size()):
		var count: int = 0
		var field: int = 0
		for card in deck.cards:
			if attributes[i] != Enum.Attribute.ANY and card.attribute == attributes[i]:
				count += 1
			if i in card.field:
				field += 1
		attribute_nodes[i].find_child("Count").text = str(count) if count > 0 else "-"
		attribute_nodes[i].find_child("Field").text = str(field) if field > 0 else "-"
	var battle_count: int = 0
	var event_count: int = 0
	var situation_count: int = 0
	var hand_count: int = 0
	var ballistic_count: int = 0
	var spread_count: int = 0
	var homing_count: int = 0
	var total_cost: int = 0
	var unlimited_count: int = 0
	for card in deck.cards:
		match card.type:
			Enum.Type.BATTLE:
				battle_count += 1
			Enum.Type.EVENT:
				event_count += 1
			Enum.Type.SITUATION:
				situation_count += 1
		match card.attack_type:
			Enum.AttackType.HAND:
				hand_count += 1
			Enum.AttackType.BALLISTIC:
				ballistic_count += 1
			Enum.AttackType.SPREAD:
				spread_count += 1
			Enum.AttackType.HOMING:
				homing_count += 1
		total_cost += card.cost
		var unlimited: bool = false
		for effect_data: EffectData in card.effects:
			for effect: String in effect_data.effects:
				if "Unlimited" in effect:
					unlimited = true
					break
		if unlimited:
			unlimited_count += 1
	$Stats/BattleCount/Value.text = str(battle_count)
	$Stats/EventCount/Value.text = str(event_count)
	$Stats/SituationCount/Value.text = str(situation_count)
	$Stats/HandCount/Value.text = str(hand_count)
	$Stats/BallisticCount/Value.text = str(ballistic_count)
	$Stats/SpreadCount/Value.text = str(spread_count)
	$Stats/HomingCount/Value.text = str(homing_count)
	$Stats/TotalCost/Value.text = str(total_cost)
	$Stats/AverageCost/Value.text = str((total_cost * 10 / deck.size()) / 10.0) if total_cost > 0 else "0"
	$Stats/UnlimitedCount/Value.text = str(unlimited_count)

func refresh_deck_list():
	$Meta/LoadDeck.clear()
	for i in DeckData.list_decks():
		$Meta/LoadDeck.add_item(i)
	if deck.name != "":
		for i in range($Meta/LoadDeck.item_count):
			if $Meta/LoadDeck.get_item_text(i) == deck.name:
				$Meta/LoadDeck.select(i)
				break

func refresh_preset_list():
	$Meta/LoadPreset.clear()
	$Meta/LoadPreset.add_item("DECK_LOAD_PRESET")
	for i in DeckData.list_presets():
		$Meta/LoadPreset.add_item(i)

func filter_card(card: CardData, regex: RegEx = null) -> bool:
	var filter_text: String = $Filters/Search.text.to_lower()
	var filter_type: Enum.Type = Enum.type_from_string(
		$Filters/Type.get_item_text($Filters/Type.get_selected_id()))
	var filter_cost: String = $Filters/Cost.text
	var filter_attribute: Enum.Attribute = Enum.attribute_from_string(
		$Filters/Attribute.get_item_text($Filters/Attribute.get_selected_id()))
	var filter_hp: String = $Filters/HP.text
	var filter_atk: String = $Filters/ATK.text
	var filter_atk_type: Enum.AttackType = Enum.attack_type_from_string(
		$Filters/AttackType.get_item_text($Filters/AttackType.get_selected_id()))
	if filter_text != "":
		if regex:
			if not (regex.search(card.get_raw_name().to_lower()) or regex.search(card.get_raw_text().to_lower())):
				return false
		else:
			if not (filter_text in card.get_raw_name().to_lower() or filter_text in card.get_raw_text().to_lower()):
				return false
	if filter_type != Enum.Type.ANY and card.type != filter_type:
		return false
	if filter_type == Enum.Type.BATTLE:
		if filter_attribute != Enum.Attribute.ANY and card.attribute != filter_attribute:
			return false
		if filter_atk_type != Enum.AttackType.ANY and card.attack_type != filter_atk_type:
			return false
		if not filter_integer(card.max_hp, filter_hp):
			return false
		if not filter_integer(card.atk, filter_atk):
			return false
	if not filter_integer(card.cost, filter_cost):
		return false
	if $Filters/FieldAny.is_on():
		if card.field.size() == 0:
			return false
	elif $Filters/FieldAny.is_off():
		if card.field.size() > 0:
			return false
	var included_attributes: Array[Enum.Attribute] = []
	var excluded_attributes: Array[Enum.Attribute] = []
	if $Filters/FieldHuman.is_on():
		included_attributes.push_back(Enum.Attribute.HUMAN)
	elif $Filters/FieldHuman.is_off():
		excluded_attributes.push_back(Enum.Attribute.HUMAN)
	if $Filters/FieldMachine.is_on():
		included_attributes.push_back(Enum.Attribute.MACHINE)
	elif $Filters/FieldMachine.is_off():
		excluded_attributes.push_back(Enum.Attribute.MACHINE)
	if $Filters/FieldGnosis.is_on():
		included_attributes.push_back(Enum.Attribute.GNOSIS)
	elif $Filters/FieldGnosis.is_off():
		excluded_attributes.push_back(Enum.Attribute.GNOSIS)
	if $Filters/FieldMonster.is_on():
		included_attributes.push_back(Enum.Attribute.MONSTER)
	elif $Filters/FieldMonster.is_off():
		excluded_attributes.push_back(Enum.Attribute.MONSTER)
	if $Filters/FieldNopon.is_on():
		included_attributes.push_back(Enum.Attribute.NOPON)
	elif $Filters/FieldNopon.is_off():
		excluded_attributes.push_back(Enum.Attribute.NOPON)
	if $Filters/FieldBlade.is_on():
		included_attributes.push_back(Enum.Attribute.BLADE)
	elif $Filters/FieldBlade.is_off():
		excluded_attributes.push_back(Enum.Attribute.BLADE)
	for i in included_attributes:
		if i not in card.field:
			return false
	for i in excluded_attributes:
		if i in card.field:
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
	for i in range($Filters/Attribute.get_popup().item_count):
		$Filters/Attribute.get_popup().set_item_icon_max_width(i, 32)
	for i in range($List/Sorting1.get_popup().item_count):
		$List/Sorting1.get_popup().set_item_icon_max_width(i, 8)
	for i in range($List/Sorting2.get_popup().item_count):
		$List/Sorting2.get_popup().set_item_icon_max_width(i, 8)
	load_cards()
	sort_card_list()
	setup_card_list()
	refresh_card_list()
	refresh_deck_list()
	refresh_preset_list()
	refresh_stats()
	$Meta/LoadDeck.select(-1)

func add_to_deck(card: CardData):
	if deck.size() < 40:
		deck.add_bottom(card)
		refresh_deck()

func remove_from_deck(index: int):
	deck.remove_at(index)
	refresh_deck()

func load_deck(deck_name: String, preset: bool = false):
	deck = DeckData.load(deck_name, preset)
	$Meta/DeckName.text = deck.name
	refresh_deck()

func preview_card(index: int, card: CardData):
	$Preview/CardDetails.visible = true
	if index != -1:
		card = all_cards[index]
	$Preview/CardDetails/CardNode.show_card(card)
	$Preview/CardDetails/CardNode.turn_up()
	var preview_text: RichTextLabel = $Preview/Text
	preview_text.clear()
	preview_text.push_font_size(20)
	preview_text.push_underline()
	preview_text.append_text(card.get_raw_name())
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
		parent.set_card(all_cards[parent.index])
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
	deck = DeckData.new()
	$Meta/DeckName.text = ""
	$Meta/LoadDeck.select(-1)
	refresh_deck()

func _on_button_exit_pressed():
	get_parent().end_scene()

func _on_button_open_deck_dir_pressed():
	OS.shell_open("%s/decks" % OS.get_user_data_dir())

func _on_field_any_toggled(new_state: int) -> void:
	refresh_card_list()

func _on_field_human_toggled(new_state: int) -> void:
	refresh_card_list()

func _on_field_machine_toggled(new_state: int) -> void:
	refresh_card_list()

func _on_field_gnosis_toggled(new_state: int) -> void:
	refresh_card_list()

func _on_field_monster_toggled(new_state: int) -> void:
	refresh_card_list()

func _on_field_nopon_toggled(new_state: int) -> void:
	refresh_card_list()

func _on_field_blade_toggled(new_state: int) -> void:
	refresh_card_list()

func _on_sorting_item_selected(index: int) -> void:
	sort_card_list()
	refresh_card_list()

func _on_search_regex_toggled(toggled_on: bool) -> void:
	if $Filters/Search.text != "":
		refresh_card_list()
