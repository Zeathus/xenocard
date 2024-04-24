extends Event

class_name EventPhaseMove

var player: Player
var phase_effects: Array
var state: int = 0

func _init(_game_board: GameBoard, _player: Player, _phase_effects: Array):
	super(_game_board)
	player = _player

func get_name() -> String:
	return "PhaseMove"

func on_start():
	pass

func on_finish():
	game_board.end_phase()

func process(delta):
	if pass_to_child("process", [delta]):
		return
	match state:
		0:
			if player.field.battler_count() == 0:
				state = 1
		1:
			for card in player.field.get_all_cards():
				for e in card.get_effects():
					e.after_move_phase()
					for event in e.get_events():
						queue_event(event)
			state = 2
		2:
			finish()

func on_zone_selected(field: GameField, zone_owner: Player, zone: Card.Zone, index: int):
	if pass_to_child("on_zone_selected", [field, zone_owner, zone, index]):
		return
	var card: Card = field.get_card(zone, index)
	if card and card.selectable(game_board):
		queue_event(EventMove.new(game_board, player, card))

func on_end_phase_pressed():
	if not has_children() and state == 0:
		state = 1
