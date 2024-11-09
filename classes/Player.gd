class_name Player

var id: int
var deck: Deck
var lost: Deck
var junk: Deck
var field: GameField
var hand: GameHand
var show_hand: bool
var reveal_hand: bool
var game_board: GameBoard
var used_one_battle_card_per_turn: bool
var used_one_situation_card_per_turn: bool
var controller: Controller
var applied_effects: Array[CardEffect]

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
	self.used_one_battle_card_per_turn = false
	self.used_one_situation_card_per_turn = false
	self.controller = null

func has_controller() -> bool:
	return self.controller != null

func can_draw() -> bool:
	return self.deck.can_draw()

func draw(do_init=true) -> Card:
	var card: Card = self.deck.draw(do_init)
	self.field.refresh()
	return card

func draw_lost(do_init=true) -> Card:
	var card: Card = self.lost.draw(do_init)
	self.field.refresh()
	return card

func pay_cost(cost: int) -> int:
	var cost_paid: int = 0
	for i in range(cost):
		var card: Card = self.deck.draw(false)
		if card:
			self.lost.add_top(card)
			cost_paid += 1
	self.field.refresh()
	return cost_paid

func recover(amt: int) -> int:
	var recovered: int = 0
	for i in range(amt):
		var card: Card = self.lost.draw(false)
		if card:
			self.deck.add_top(card)
			recovered += 1
	self.field.refresh()
	return recovered

func take_damage(game_board: GameBoard, attacker: Card, damage: int, source: Damage):
	for e in applied_effects:
		damage = e.take_damage(game_board, attacker, damage, source)
	if damage < 0:
		damage = 0
	for i in range(damage):
		var card: Card = self.deck.draw(false)
		if card:
			self.lost.add_top(card)
	self.field.refresh()
	return damage

func get_resources() -> Array[Enum.Attribute]:
	var resources: Array[Enum.Attribute] = []
	for card in self.field.get_all_cards():
		for attr in card.get_resources():
			resources.push_back(attr)
	return resources

func get_enemy() -> Player:
	for p in game_board.players:
		if p != self:
			return p
	return null

func set_reveal_hand(val: bool):
	reveal_hand = val
	for card in hand.cards:
		if reveal_hand or show_hand:
			card.instance.turn_up()
		else:
			card.instance.turn_down()

func can_end_phase(phase: Enum.Phase):
	for card in game_board.get_all_field_cards():
		for e in card.get_effects(Enum.Trigger.PASSIVE):
			if not e.can_end_phase(phase, self):
				return false
	return true

func is_card() -> bool:
	return false

func is_player() -> bool:
	return true

func get_behind():
	return null
