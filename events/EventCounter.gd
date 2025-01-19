extends Event

class_name EventCounter

static var confirm_scene = load("res://scenes/menu_confirm.tscn")
var player: Player
var countered_card: Card
var countering_card: Card
var menu = null
var chain: Array[Card]

func _init(_game_board: GameBoard, _player: Player, _countered_card: Card, _countering_card: Card, _chain: Array[Card] = []):
	super(_game_board)
	player = _player
	countered_card = _countered_card
	countering_card = _countering_card
	for i in _chain:
		chain.push_back(i)

func get_name() -> String:
	return "Counter"

func on_start():
	broadcast()
	play(countering_card)

func on_finish():
	game_board.countering_player = null
	if player.has_controller():
		return

func process(delta):
	if pass_to_child("process", [delta]):
		return
	finish()

func play(card: Card):
	if card.instance.is_face_down() and card.zone == Enum.Zone.HAND and game_board.online_mode == 0:
		for i in range(player.hand.size()):
			if player.hand.cards[i].instance.is_face_down():
				if player.hand.cards.find(card) <= i:
					break
				player.hand.cards.erase(card)
				player.hand.cards.insert(i, card)
				player.hand.refresh()
				break
	countering_card = card
	var cost_to_pay = card.get_cost()
	var cost_paid: int = player.pay_cost(cost_to_pay)
	card.revealed = true
	if card.instance.is_face_down():
		queue_event(EventAnimation.new(game_board, AnimationFlip.new(card)))
	for i in range(cost_paid):
		queue_event(EventPayCost.new(game_board, player))
	queue_event(EventAnimation.new(game_board, AnimationEffectStart.new(card)))
	queue_event(EventCounterPrompt.new(game_board, player.get_enemy(), card, chain))
	card.trigger_effects(Enum.Trigger.COUNTER, self, {"countered": countered_card})
	queue_event(EventAnimation.new(game_board, AnimationEffectEnd.new(card)))

func broadcast():
	if game_board.is_server():
		player.get_enemy().controller.send_identity(countering_card.get_online_id(player.id == 0), countering_card.data.get_full_id())
		for p: Player in [game_board.get_turn_player(), game_board.get_turn_enemy()]:
			var args: Array = [countered_card.get_online_id(p.id == 1), countering_card.get_online_id(p.id == 1)]
			for card in chain:
				args.push_back(card.get_online_id(p.id == 1))
			p.controller.broadcast_event(get_name(), args)
