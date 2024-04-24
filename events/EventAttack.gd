extends Event

class_name EventAttack

var player: Player
var attacker: Card
var targets: Array
var attack_done: bool = false
var handled_post_effects: bool = false

func _init(_game_board: GameBoard, _attacker):
	super(_game_board)
	attacker = _attacker
	start()

func get_name() -> String:
	return "Attack"

func on_start():
	for e in attacker.get_effects():
		if e.attack_stopped():
			finish()
			return
	var anim_targets: Array[Node2D] = []
	for t in attacker.get_attack_targets(game_board):
		targets.push_back(t)
		anim_targets.push_back(t.instance if t.is_card() else t.field.get_deck_node())
	if len(targets) == 0:
		attacker.atk_timer = 0
		finish()
		return
	var anim: AttackAnimation = AttackAnimation.new(attacker.instance, anim_targets)
	queue_event(EventAnimation.new(game_board, anim))

func on_finish():
	game_board.refresh()

func process(delta):
	sort_children()
	if pass_to_child("process", [delta]):
		return
	if not attack_done:
		attack_done = true
		attack()
	elif not handled_post_effects:
		handled_post_effects = true
		attacker.atk_timer = 0
		game_board.refresh()
		if len(targets) == 0:
			return
		for e in attacker.get_effects():
			e.after_attack_hit(targets)
			for event in e.get_events():
				queue_event(event)
				game_board.refresh()
	else:
		finish()

func attack():
	if len(targets) == 0:
		return
	for t in targets:
		var behind_target = t.get_behind()
		var damage_event: EventDamage = EventDamage.new(game_board, attacker, t, attacker.get_atk(t), Damage.new(Damage.BATTLE | Damage.NORMAL_ATTACK))
		adopt_children(damage_event)
		queue_event(damage_event)
		var remaining_damage = damage_event.remaining_damage
		for e in attacker.get_effects():
			if t.is_player():
				e.on_deck_attacked(t)
			else:
				e.on_target_attacked(t)
		if remaining_damage > 0 and behind_target and attacker.penetrates():
			penetrating_attack(game_board, behind_target, remaining_damage)
	sort_children()

func penetrating_attack(game_board: GameBoard, target_to_hit, remaining_damage: int) -> bool:
	if remaining_damage <= 0:
		return false
	var behind_target = target_to_hit.get_behind()
	var damage_event: EventDamage = EventDamage.new(game_board, attacker, target_to_hit, remaining_damage, Damage.new(Damage.BATTLE | Damage.NORMAL_ATTACK | Damage.PENETRATING))
	adopt_children(damage_event)
	queue_event(damage_event)
	remaining_damage = damage_event.remaining_damage
	for e in attacker.get_effects():
		if target_to_hit.is_player():
			e.on_deck_attacked(target_to_hit)
		else:
			e.on_target_attacked(target_to_hit)
	if remaining_damage > 0 and behind_target and attacker.penetrates():
		penetrating_attack(game_board, behind_target, remaining_damage)
	return true
