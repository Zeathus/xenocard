extends Event

class_name EventPhaseSet

var player: Player
var phase_effects: Array

func _init(_game_board: GameBoard, _player: Player, _phase_effects: Array):
	super(_game_board)
	player = _player

func get_name() -> String:
	return "PhaseSet"

func on_start():
	pass

func on_finish():
	game_board.end_phase()

func process(delta):
	if pass_to_child("process", [delta]):
		return

func on_hand_card_selected(hand: GameHand, card: Card):
	if pass_to_child("on_hand_card_selected", [hand, card]):
		return
	if card.selectable(game_board):
		queue_event(EventSet.new(game_board, player, card))

func on_zone_selected(field: GameField, zone_owner: Player, zone: Card.Zone, index: int):
	if pass_to_child("on_zone_selected", [field, zone_owner, zone, index]):
		return

func on_end_phase_pressed():
	if not has_children():
		finish()
