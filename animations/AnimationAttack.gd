extends GameAnimation

class_name AnimationAttack

static var projectile_scene = load("res://animations/projectile.tscn")
var game_board: GameBoard
var attacker: Node2D
var targets: Array[Node2D]
var atk: int
var attack_type: Enum.AttackType
var projectiles: Array[Node2D]
var time: float
var move_end_time: float = 0.5
var scale_time: float = 1.0
var target_scale: float = 0.5

func _init(_game_board: GameBoard, _attacker: Node2D, _targets: Array[Node2D], _atk: int, _attack_type: Enum.AttackType):
	self.game_board = _game_board
	self.attacker = _attacker
	self.targets = _targets
	self.atk = _atk
	self.attack_type = _attack_type
	self.projectiles = []
	self.time = 0
	scale_time = 1.0 + 0.025 * (min(_atk, 10) ** 2)
	target_scale = 0.5 + 0.025 * (min(_atk, 10) ** 2)

func make_projectile(target: Node2D):
	var p: Node2D = projectile_scene.instantiate()
	attacker.add_child(p)
	p.global_position = attacker.global_position
	p.scale = Vector2(0, 0)
	projectiles.push_back(p)

func finish():
	if targets.size() == 0:
		pass
	elif attack_type == Enum.AttackType.HAND:
		for t in targets:
			if t.has_method("play_animation"):
				t.play_animation("HitByHand")
		attacker.play_animation("AttackHand2")
		attacker.disable_in_motion_after_animation = true
	else:
		for t in targets:
			if t.has_method("play_animation"):
				t.play_animation("HitByAttack")
	super()

func update(delta):
	if is_done():
		return
	if targets.size() == 0:
		if time == 0:
			attacker.in_motion = true
			attacker.play_animation("CannotAttack")
			attacker.disable_in_motion_after_animation = true
		time += delta
		if not attacker.animating():
			finish()
		return
	match attack_type:
		Enum.AttackType.HAND:
			if time == 0:
				attacker.in_motion = true
				attacker.play_animation("AttackHand")
			time += delta
			for t in targets:
				if t.animating():
					return
			if not attacker.animating():
				finish()
		_:
			if time == 0:
				for t in targets:
					make_projectile(t)
				attacker.play_animation("ChargeAttack", 1.0 / scale_time)
				game_board.play_se("charge_%d" % min(atk, 10), -4)
			if time < scale_time and time + delta >= scale_time:
				game_board.play_se("shoot_" + str(randi_range(1, 5)), -8, 1.0 / (scale_time ** 0.5))
			time += delta
			var move_progress: float = min(time - scale_time, move_end_time)
			for i in range(len(targets)):
				var t = targets[i]
				var p = projectiles[i]
				if move_progress < 0:
					p.global_position = attacker.global_position
					p.scale = (Vector2(target_scale, target_scale) * min((scale_time + move_progress) / scale_time, 1.0)) / attacker.scale
				else:
					p.global_position = t.global_position * (move_progress / move_end_time) + \
						attacker.global_position * ((move_end_time - move_progress) / move_end_time)
			if move_progress >= move_end_time:
				for p in projectiles:
					attacker.remove_child(p)
					p.queue_free()
				projectiles.clear()
				finish()
