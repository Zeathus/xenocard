extends Event

class_name EventPhaseBattle

var player: Player
var phase_effects: Array
var to_attack: Array[Card] = []
var last_attacker: Card = null

func _init(_game_board: GameBoard, _player: Player, _phase_effects: Array):
	super(_game_board)
	player = _player

func get_name() -> String:
	return "PhaseBattle"

func on_start():
	var target_order = [
		Card.Target.HAND,
		Card.Target.BALLISTIC,
		Card.Target.SPREAD,
		Card.Target.HOMING
	]
	for target in target_order:
		for card in player.field.get_battlefield_cards():
			if card.get_target() == target:
				to_attack.push_back(card)
		for card in player.get_enemy().field.get_battlefield_cards():
			if card.get_target() == target and card.can_attack_on_enemy_phase():
				to_attack.push_back(card)

func on_finish():
	game_board.end_phase()

func process(delta):
	if pass_to_child("process", [delta]):
		return
	if last_attacker:
		if last_attacker.zone == Card.Zone.BATTLEFIELD:
			for e in last_attacker.get_effects():
				e.after_attack_turn()
				for event in e.get_events():
					queue_event(event)
		last_attacker = null
		if has_children():
			return
	if len(to_attack) > 0:
		var attacker: Card = to_attack.pop_front()
		if attacker.can_attack(game_board):
			attacker.atk_timer += 1
			game_board.refresh()
			if attacker.atk_timer >= attacker.get_atk_time():
				queue_event(EventAttack.new(game_board, attacker))
		last_attacker = attacker
		return
	finish()
