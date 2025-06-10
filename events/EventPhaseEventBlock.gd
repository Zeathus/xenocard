extends Event

class_name EventPhaseEventBlock

var player: Player
var phase_effects: Array
var block: bool
var in_sub_event: bool = false
var time: float = 0

func _init(_game_board: GameBoard, _player: Player, _phase_effects: Array, _block: bool = false):
	super(_game_board)
	player = _player
	block = _block

func get_name() -> String:
	return "PhaseBlock" if block else "PhaseEvent"

func on_start():
	broadcast_player(player)
	queue_event(EventStartPhase.new(game_board, player, Enum.Phase.BLOCK if block else Enum.Phase.EVENT))
	if not player.has_controller():
		show_selectable()

func on_finish():
	hide_selectable()
	game_board.get_hint_node().fade_out()
	game_board.end_phase()

func process(delta):
	if pass_to_child("process", [delta]):
		time = 0
		game_board.get_hint_node().fade_out()
		return
	if time < 5 and time + delta >= 5 and not Options.disable_block_reminder:
		if not player.has_controller() and block:
			game_board.get_hint_node().set_hint("It is your Block Phase")
			game_board.get_hint_node().set_pos(HintNode.Position.CENTER)
			game_board.get_hint_node().fade_in()
	time += delta
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
	if card:
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

func on_end_phase_pressed():
	if can_end_phase():
		if player.get_enemy().is_online():
			player.get_enemy().controller.send_action(Controller.Action.END_PHASE)
		finish()

func can_end_phase():
	return started and (not has_children()) and player.can_end_phase(Enum.Phase.BLOCK if block else Enum.Phase.EVENT)

func play(card: Card):
	if player.get_enemy().is_online():
		var args: Array[String] = [card.get_online_id()]
		var action: Controller.Action = Controller.Action.BLOCK if block else Controller.Action.EVENT
		player.get_enemy().controller.send_action(action, args)
	queue_event(EventEvent.new(game_board, card, block))
	in_sub_event = true
	hide_selectable()
