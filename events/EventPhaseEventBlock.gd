extends Event

class_name EventPhaseEventBlock

var player: Player
var phase_effects: Array
var block: bool
var in_sub_event: bool = false

func _init(_game_board: GameBoard, _player: Player, _phase_effects: Array, _block: bool = false):
	super(_game_board)
	player = _player
	block = _block

func get_name() -> String:
	return "PhaseEvent"

func on_start():
	queue_event(EventStartPhase.new(game_board, player, Enum.Phase.BLOCK if block else Enum.Phase.EVENT))
	if not player.has_controller():
		show_selectable()

func on_finish():
	hide_selectable()
	game_board.end_phase()

func process(delta):
	if pass_to_child("process", [delta]):
		return
	if in_sub_event:
		in_sub_event = false
		if not player.has_controller():
			show_selectable()
	if player.has_controller() and not player.controller.is_waiting():
		if player.controller.has_response():
			player.controller.receive()
		else:
			var action = Controller.Action.BLOCK if block else Controller.Action.EVENT
			player.controller.request(
				[action, Controller.Action.END_PHASE],
				[activate_card, on_end_phase_pressed]
			)

func show_selectable():
	for card in player.hand.cards:
		var valid: bool = card.selectable(game_board)
		card.set_selectable(valid)
	for card in player.field.get_all_cards():
		var valid: bool = card.selectable(game_board)
		card.set_selectable(valid)

func hide_selectable():
	for card in player.hand.cards:
		card.set_selectable(false)
	for card in player.field.get_all_cards():
		card.set_selectable(false)

func activate_card(card: Card):
	if has_children():
		return
	if card and card.selectable(game_board):
		play(card)

func on_hand_card_selected(hand: GameHand, card: Card):
	if pass_to_child("on_hand_card_selected", [hand, card]):
		return
	if player.has_controller():
		return
	if card.selectable(game_board):
		play(card)

func on_zone_selected(field: GameField, zone_owner: Player, zone: Enum.Zone, index: int):
	if pass_to_child("on_zone_selected", [field, zone_owner, zone, index]):
		return
	if player.has_controller():
		return
	var card: Card = field.get_card(zone, index)
	if card and card.selectable(game_board):
		play(card)

func play(card: Card):
	if card.instance.is_face_down() and card.zone == Enum.Zone.HAND:
		for i in range(player.hand.size()):
			if player.hand.cards[i].instance.is_face_down():
				if player.hand.cards.find(card) <= i:
					break
				player.hand.cards.erase(card)
				player.hand.cards.insert(i, card)
				player.hand.refresh()
				break
	hide_selectable()
	var cost_to_pay = card.get_cost()
	var cost_paid: int = player.pay_cost(cost_to_pay)
	card.revealed = true
	if card.instance.is_face_down():
		queue_event(EventAnimation.new(game_board, AnimationFlip.new(card)))
	for i in range(cost_paid):
		queue_event(EventPayCost.new(game_board, player))
	queue_event(EventAnimation.new(game_board, AnimationEffectStart.new(card)))
	if card.get_type() == Enum.Type.EVENT:
		queue_event(EventCounter.new(game_board, player.get_enemy(), card))
	card.trigger_effects(Enum.Trigger.ACTIVATE, self, {"block": block})
	queue_event(EventAnimation.new(game_board, AnimationEffectEnd.new(card)))
	in_sub_event = true

func on_end_phase_pressed():
	if not has_children():
		if player.can_end_phase(Enum.Phase.BLOCK):
			finish()
