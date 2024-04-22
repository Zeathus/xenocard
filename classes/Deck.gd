class_name Deck

var name: String
var cards: Array[Card]

func _init():
	self.name = ""
	self.cards = []

func size() -> int:
	return len(self.cards)

func shuffle():
	self.cards.shuffle()

func can_draw() -> bool:
	return len(cards) > 0

func draw(do_init: bool) -> Card:
	var card = self.cards.pop_front()
	if card and do_init:
		card.instantiate()
	return card

func draw_at(index: int) -> Card:
	var card = self.cards[index]
	self.cards.remove_at(index)
	card.instantiate()
	return card

func add(card: Card):
	cards.push_back(card)

func top() -> Card:
	return self.cards.back()

func remove_at(index: int):
	cards.remove_at(index)

func erase(card: Card):
	cards.erase(card)

func set_owner(player: Player):
	for card in self.cards:
		card.owner = player

func save():
	DirAccess.make_dir_absolute("user://decks/")
	var deck_file = FileAccess.open("user://decks/%s.json" % name, FileAccess.WRITE)
	var json_data: Dictionary = {
		"name": name,
		"cards": []
	}
	for card in cards:
		json_data["cards"].push_back("%s/%s" % [card.set_name, card.id])
	var json_string = JSON.stringify(json_data)
	deck_file.store_line(json_string)

func sort():
	cards.sort_custom(func compare(a, b):
		if a.set_id < b.set_id:
			return true
		return false
	)

static func load(name: String) -> Deck:
	var file_name: String = "user://decks/%s.json" % name
	if FileAccess.file_exists(file_name):
		var file = FileAccess.open(file_name, FileAccess.READ)
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		if error == OK:
			var deck = Deck.new()
			deck.name = json.data["name"]
			for i in json.data["cards"]:
				deck.cards.push_back(Card.new(i))
			return deck
		else:
			push_error("Failed to to parse deck file '%s'" % file_name)
	else:
		push_error("Failed to find deck file '%s'" % file_name)
	return null

static func list_decks() -> Array[String]:
	var dir = DirAccess.open("user://decks/")
	var deck_names: Array[String] = []
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				var deck_name = file_name.substr(0, file_name.find(".json"))
				deck_names.push_back(deck_name)
			file_name = dir.get_next()
	return deck_names
