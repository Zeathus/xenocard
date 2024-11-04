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

func add_bottom(card: Card):
	cards.push_back(card)

func add_top(card: Card):
	cards.push_front(card)

func top() -> Card:
	return self.cards.front()

func remove_at(index: int):
	cards.remove_at(index)

func erase(card: Card):
	cards.erase(card)

func clear():
	cards.clear()

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
		json_data["cards"].push_back("%s/%s" % [card.get_set_name(), card.get_id()])
	var json_string = JSON.stringify(json_data)
	deck_file.store_line(json_string)

func sort():
	cards.sort_custom(func compare(a, b):
		if a.get_set_id() < b.get_set_id():
			return true
		return false
	)

static func load(name: String, preset: bool = false) -> Deck:
	var deck_data = DeckData.load(name, preset)
	var deck = Deck.new()
	deck.name = deck_data.name
	for card_data in deck_data.cards:
		deck.cards.push_back(Card.new(card_data.get_full_id()))
	return deck
