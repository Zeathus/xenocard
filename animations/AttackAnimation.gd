extends GameAnimation

class_name AttackAnimation

static var projectile_scene = preload("res://animations/projectile.tscn")
var attacker: Node2D
var targets: Array[Node2D]
var projectiles: Array[Node2D]
var time: float
var move_end_time: float = 1.0

func _init(attacker: Node2D, targets: Array[Node2D]):
	self.attacker = attacker
	self.targets = targets
	self.projectiles = []
	self.time = 0

func make_projectile(target: Node2D):
	var p: Node2D = projectile_scene.instantiate()
	attacker.add_child(p)
	p.global_position = attacker.global_position
	p.scale = Vector2(1.0, 1.0) / attacker.scale
	projectiles.push_back(p)

func update(delta):
	if is_done():
		return
	if time == 0:
		for t in targets:
			make_projectile(t)
	time += delta
	var move_progress: float = min(time, move_end_time)
	for i in range(len(targets)):
		var t = targets[i]
		var p = projectiles[i]
		p.global_position = t.global_position * (move_progress / move_end_time) + \
			attacker.global_position * ((move_end_time - move_progress) / move_end_time)
	if time >= move_end_time:
		for p in projectiles:
			attacker.remove_child(p)
			p.queue_free()
		finish()
