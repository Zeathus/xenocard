extends Event

class_name EventPhaseDraw

var player: Player
var phase_effects: Array

func _init(_game_board: GameBoard, _player: Player, _phase_effects: Array):
	super(_game_board)
	player = _player

func get_name() -> String:
	return "PhaseDraw"

func on_start():
	for c in player.field.get_all_cards():
		c.on_turn_start(false)
		c.trigger_effects(Enum.Trigger.TURN_START, self)
		c.trigger_effects(Enum.Trigger.TURN_START_PLAYER, self)
	for c in player.get_enemy().field.get_all_cards():
		c.on_turn_start(true)
		c.trigger_effects(Enum.Trigger.TURN_START, self)
		c.trigger_effects(Enum.Trigger.TURN_START_ENEMY, self)

	queue_event(EventStartPhase.new(game_board, player, Enum.Phase.DRAW))

	var can_normal_draw = true
	for c in player.field.get_all_cards():
		for e in c.get_effects(Enum.Trigger.PASSIVE):
			if e.stops_normal_draw():
				can_normal_draw = false
	if can_normal_draw and player.can_draw():
		queue_event(EventDrawCard.new(game_board, player))

	for c in player.field.get_all_cards():
		c.trigger_effects(Enum.Trigger.AFTER_NORMAL_DRAW, self)
		c.trigger_effects(Enum.Trigger.AFTER_NORMAL_DRAW_PLAYER, self)
	for c in player.get_enemy().field.get_all_cards():
		c.trigger_effects(Enum.Trigger.AFTER_NORMAL_DRAW, self)
		c.trigger_effects(Enum.Trigger.AFTER_NORMAL_DRAW_ENEMY, self)

func on_finish():
	game_board.end_phase()

func process(delta):
	if pass_to_child("process", [delta]):
		return
	finish()
