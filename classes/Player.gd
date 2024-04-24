class_name Player

var id: int
var deck: Deck
var lost: Deck
var junk: Deck
var field: GameField
var hand: GameHand
var show_hand: bool
var game_board: GameBoard
var used_one_card_per_turn: bool

func _init(id: int, deck: Deck, field: GameField, hand: GameHand, game_board: GameBoard):
	self.id = id
	self.deck = deck
	self.deck.set_owner(self)
	self.deck.shuffle()
	self.lost = Deck.new()
	self.junk = Deck.new()
	self.field = field
	self.hand = hand
	self.show_hand = false
	self.game_board = game_board
	self.hand.game_board = game_board
	self.field.game_board = game_board
	self.field.set_player(self)
	self.used_one_card_per_turn = false

func can_draw() -> bool:
	return self.deck.can_draw()

func draw(do_init=true) -> Card:
	var card: Card = self.deck.draw(do_init)
	self.field.refresh()
	return card

func pay_cost(cost: int) -> int:
	var cost_paid: int = 0
	for i in range(cost):
		var card: Card = self.deck.draw(false)
		if card:
			self.lost.add(card)
			cost_paid += 1
	self.field.refresh()
	return cost_paid

func take_damage(game_board: GameBoard, attacker: Card, damage: int, source: Damage):
	for i in range(damage):
		var card: Card = self.deck.draw(false)
		if card:
			self.lost.add(card)
	self.field.refresh()
	return damage

func get_resources() -> Array[Card.Attribute]:
	var resources: Array[Card.Attribute] = []
	for card in self.field.get_all_cards():
		for attr in card.get_resources():
			resources.push_back(attr)
	return resources

func get_enemy() -> Player:
	for p in game_board.players:
		if p != self:
			return p
	return null

func is_card() -> bool:
	return false

func is_player() -> bool:
	return true

func get_behind():
	return null
