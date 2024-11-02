extends Event

class_name EventPhaseBattle

var player: Player
var phase_effects: Array
var to_attack: Array[Card] = []
var last_attacker: Card = null
var state: int = 0

func _init(_game_board: GameBoard, _player: Player, _phase_effects: Array):
	super(_game_board)
	player = _player

func get_name() -> String:
	return "PhaseBattle"

func on_start():
	pass

func on_finish():
	game_board.end_phase()

func process(delta):
	if pass_to_child("process", [delta]):
		return
	match state:
		0:
			for card in player.field.get_all_cards():
				var old_value = card.e_mark
				card.set_e_mark(false)
				if old_value and not card.e_mark:
					card.trigger_effects(Enum.Trigger.E_MARK_REMOVED, self)
			if game_board.skips_phase(Enum.Phase.BATTLE, player):
				finish()
		1:
			var target_order = [
				Enum.AttackType.HAND,
				Enum.AttackType.BALLISTIC,
				Enum.AttackType.SPREAD,
				Enum.AttackType.HOMING
			]
			for target in target_order:
				for card in player.field.get_battlefield_cards():
					if card.get_attack_type() == target:
						to_attack.push_back(card)
				for card in player.get_enemy().field.get_battlefield_cards():
					if card.get_attack_type() == target and card.can_attack_on_enemy_phase():
						to_attack.push_back(card)
		2:
			if last_attacker:
				if last_attacker.zone == Enum.Zone.BATTLEFIELD:
					last_attacker.trigger_effects(Enum.Trigger.AFTER_ATTACK_TIMING, self)
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
		3:
			finish()
	state += 1
