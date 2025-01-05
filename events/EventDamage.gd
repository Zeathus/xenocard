extends Event

class_name EventDamage

var attacker: Card
var target
var damage: int
var source: Damage
var remaining_damage: int = 0

func _init(_game_board: GameBoard, _attacker: Card, _target, _damage: int, _source: Damage):
	broadcasted = false
	super(_game_board)
	attacker = _attacker
	target = _target
	damage = _damage
	source = _source
	start()

func get_priority():
	return 20

func get_name() -> String:
	return "Damage"

func on_start():
	if target.is_player():
		target.take_damage(game_board, attacker, damage, source)
		return
	for e in target.get_effects(Enum.Trigger.PASSIVE):
		damage = e.take_damage(game_board, attacker, damage, source)
	for e in target.get_effects(Enum.Trigger.PASSIVE):
		damage = e.take_set_damage(game_board, attacker, damage, source)
	var new_hp: int = max(target.hp - damage, 0)
	var capped_damage = target.hp - new_hp
	target.hp = new_hp
	if target.is_destroyed():
		queue_event(EventDestroy.new(game_board, attacker, target, Damage.new(source.flags | Damage.DESTROY)))
	remaining_damage = max(damage - capped_damage, 0)
	game_board.refresh()

func on_finish():
	pass

func process(delta):
	if pass_to_child("process", [delta]):
		return
	finish()

func broadcast():
	if game_board.is_server():
		for p: Player in [game_board.get_turn_player(), game_board.get_turn_enemy()]:
			var args: Array = [
				attacker.get_online_id(p.id == 1),
				"player" if target.is_player() else target.get_online_id(p.id == 1),
				damage,
				source.get_online_id()
			]
			p.controller.broadcast_event(get_name(), args)
