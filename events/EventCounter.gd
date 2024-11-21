extends Event

class_name EventCounter

static var confirm_scene = load("res://scenes/menu_confirm.tscn")
var player: Player
var countered_card: Card
var menu = null
var state: int = 0
var can_counter: bool = false
var chain: Array[Card]

func _init(_game_board: GameBoard, _player: Player, _countered_card: Card, _chain: Array[Card] = []):
	super(_game_board)
	player = _player
	countered_card = _countered_card
	for i in _chain:
		chain.push_back(i)
	chain.push_back(countered_card)

func get_name() -> String:
	return "Counter"

func on_start():
	game_board.countering_player = player
	can_counter = false
	for c in player.hand.cards:
		if c not in chain and c.selectable(game_board):
			can_counter = true
			break
	if not can_counter:
		for c in player.field.get_all_cards():
			if c not in chain and c.selectable(game_board):
				can_counter = true
				break
	if player.has_controller():
		return
	var message = "The enemy played an Event card"
	var help_text = \
		"Do you want to use a card to counter the enemy Event card?" \
		if can_counter else \
		"You have no cards to neutralize the enemy Event card."
	menu = confirm_scene.instantiate()
	menu.set_message(message)
	menu.set_help(help_text)
	menu.set_card(countered_card)
	menu.set_handler(handle_answer)
	if not can_counter:
		menu.set_yes_only()
	game_board.add_menu(menu)

func on_finish():
	game_board.countering_player = null
	if player.has_controller():
		return

func process(delta):
	if pass_to_child("process", [delta]):
		return
	match state:
		0:
			if player.has_controller():
				if not player.controller.is_waiting():
					if player.controller.has_response():
						player.controller.receive()
					else:
						player.controller.request(
							[Controller.Action.CONFIRM],
							[func(x): handle_answer(x); state = 1 if can_counter else 3]
						)
			elif menu and menu.is_done():
				game_board.remove_menu(menu)
				menu.finish()
				state = 1 if can_counter else 3
		1:
			show_selectable()
			state = 2
		2:
			if player.has_controller():
				if not player.controller.is_waiting():
					if player.controller.has_response():
						player.controller.receive()
					else:
						player.controller.request(
							[Controller.Action.COUNTER],
							[func(x): play(x)],
							[[chain]]
						)
		3:
			finish()

func handle_answer(answer: bool):
	if can_counter:
		can_counter = answer

func show_selectable():
	for card in player.hand.cards:
		var valid: bool = card not in chain and card.selectable(game_board)
		card.set_selectable(valid)
	for card in player.field.get_all_cards():
		var valid: bool = card not in chain and card.selectable(game_board)
		card.set_selectable(valid)

func hide_selectable():
	for card in player.hand.cards:
		card.set_selectable(false)
	for card in player.field.get_all_cards():
		card.set_selectable(false)

func on_hand_card_selected(hand: GameHand, card: Card):
	if pass_to_child("on_hand_card_selected", [hand, card]):
		return
	if player.has_controller():
		return
	if card not in chain and card.selectable(game_board):
		play(card)

func on_zone_selected(field: GameField, zone_owner: Player, zone: Enum.Zone, index: int):
	if pass_to_child("on_zone_selected", [field, zone_owner, zone, index]):
		return
	if player.has_controller():
		return
	var card: Card = field.get_card(zone, index)
	if card and card not in chain and card.selectable(game_board):
		play(card)

func play(card: Card):
	hide_selectable()
	var cost_to_pay = card.get_cost()
	var cost_paid: int = player.pay_cost(cost_to_pay)
	if card.instance.is_face_down():
		queue_event(EventAnimation.new(game_board, AnimationFlip.new(card)))
	for i in range(cost_paid):
		queue_event(EventPayCost.new(game_board, player))
	queue_event(EventAnimation.new(game_board, AnimationEffectStart.new(card)))
	queue_event(EventCounter.new(game_board, player.get_enemy(), card, chain))
	card.trigger_effects(Enum.Trigger.COUNTER, self, {"countered": countered_card})
	queue_event(EventAnimation.new(game_board, AnimationEffectEnd.new(card)))
	state = 3
