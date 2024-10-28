extends Event

class_name EventPhaseMove

var player: Player
var phase_effects: Array
var state: int = 0
var in_sub_event: bool = false

func _init(_game_board: GameBoard, _player: Player, _phase_effects: Array):
	super(_game_board)
	player = _player

func get_name() -> String:
	return "PhaseMove"

func on_start():
	if not player.has_controller():
		show_selectable()

func on_finish():
	hide_selectable()
	game_board.end_phase()

func process(delta):
	if pass_to_child("process", [delta]):
		return
	match state:
		0:
			if player.field.battler_count() == 0:
				state = 1
			if in_sub_event:
				in_sub_event = false
				show_selectable()
			elif player.has_controller() and not player.controller.is_waiting():
				if player.controller.has_response():
					player.controller.receive()
				else:
					player.controller.request(
						[Controller.Action.MOVE, Controller.Action.END_PHASE],
						[move_card, on_end_phase_pressed]
					)
		1:
			hide_selectable()
			for card in player.field.get_all_cards():
				card.trigger_effects(Enum.Trigger.AFTER_MOVE_PHASE, self)
			state = 2
		2:
			finish()

func move_card(card: Card, zone: Enum.Zone, index: int):
	var move_event: EventMove = EventMove.new(game_board, player, card)
	move_event.on_zone_selected(player.field, player, zone, index)
	queue_event(move_event)

func on_zone_selected(field: GameField, zone_owner: Player, zone: Enum.Zone, index: int):
	if pass_to_child("on_zone_selected", [field, zone_owner, zone, index]):
		return
	if player.has_controller():
		return
	var card: Card = field.get_card(zone, index)
	if card and card.selectable(game_board):
		hide_selectable()
		queue_event(EventMove.new(game_board, player, card))
		in_sub_event = true

func on_end_phase_pressed():
	if not has_children() and state == 0:
		state = 1

func show_selectable():
	for card in player.field.get_battler_cards():
		var valid: bool = card.can_move()
		card.set_selectable(valid)

func hide_selectable():
	for card in player.field.get_battler_cards():
		card.set_selectable(false)
