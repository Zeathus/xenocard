extends Event

class_name EventDamage

var attacker: Card
var target
var damage: int
var source: Damage
var remaining_damage: int = 0

func _init(_game_board: GameBoard, _attacker: Card, _target, _damage: int, _source: Damage):
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
	for e in target.get_effects():
		damage = e.take_damage(game_board, attacker, damage, source)
	for e in target.get_effects():
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
