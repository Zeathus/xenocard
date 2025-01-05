extends Event

class_name EventAttack

var player: Player
var attacker: Card
var targets: Array
var attack_done: bool = false
var handled_post_effects: bool = false

func _init(_game_board: GameBoard, _attacker: Card):
	super(_game_board)
	attacker = _attacker
	start()

func get_name() -> String:
	return "Attack"

func on_start():
	broadcast()
	for e in attacker.get_effects(Enum.Trigger.PASSIVE):
		if e.attack_stopped():
			attack_done = true
			return
	var anim_targets: Array[Node2D] = []
	for t in attacker.get_attack_targets(game_board):
		targets.push_back(t)
		anim_targets.push_back(t.instance if t.is_card() else t.field.get_deck_node().find_child("Card"))
	if len(targets) == 0:
		attack_done = true
		return
	var anim: AnimationAttack = AnimationAttack.new(attacker.instance, anim_targets, attacker.get_atk(), attacker.get_attack_type())
	queue_event(EventAnimation.new(game_board, anim))

func on_finish():
	game_board.refresh()

func process(delta):
	if attack_done and is_animating():
		return
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
		attacker.trigger_effects(Enum.Trigger.AFTER_ATTACK, self)
		game_board.refresh()
	else:
		finish()

func attack():
	if len(targets) == 0:
		return
	var atk = attacker.get_atk()
	if attacker.get_attack_type() == Enum.AttackType.HAND:
		if atk <= 3:
			game_board.play_se("hit_small" + str(randi_range(1, 2)))
		else:
			game_board.play_se("hit_medium" + str(randi_range(1, 2)))
	else:
		pass #game_board.play_se("explosion_small" + str(randi_range(1, 4)))
		#if atk <= 2:
			#game_board.play_se("explosion_small")
		#elif atk <= 7:
			#game_board.play_se("explosion_medium")
		#else:
			#game_board.play_se("explosion_massive")
	for t in targets:
		var behind_target = t.get_behind()
		var damage_event: EventDamage = EventDamage.new(game_board, attacker, t, attacker.get_atk_against(t), Damage.new(Damage.BATTLE | Damage.NORMAL_ATTACK))
		adopt_children(damage_event)
		queue_event(damage_event)
		var remaining_damage = damage_event.remaining_damage
		if t.is_player():
			attacker.trigger_effects(Enum.Trigger.DECK_HIT, self, {"damage": damage_event.damage})
		else:
			attacker.trigger_effects(Enum.Trigger.ATTACK_HIT, self, {"damage": damage_event.damage, "target": t})
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
	if target_to_hit.is_player():
		attacker.trigger_effects(Enum.Trigger.DECK_HIT, self)
	else:
		attacker.trigger_effects(Enum.Trigger.ATTACK_HIT, self, {"target": target_to_hit})
	if remaining_damage > 0 and behind_target and attacker.penetrates():
		penetrating_attack(game_board, behind_target, remaining_damage)
	return true

func is_animating() -> bool:
	if attacker.instance and attacker.instance.animating():
		return true
	for t in targets:
		if t.is_card() and t.instance and t.instance.animating():
			return true
	return false

func broadcast():
	if game_board.is_server():
		for p: Player in [game_board.get_turn_player(), game_board.get_turn_enemy()]:
			var args: Array = [attacker.get_online_id(p.id == 1)]
			p.controller.broadcast_event(get_name(), args)
