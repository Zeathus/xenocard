extends Event

class_name EventDestroy

var attacker: Card
var target: Card
var source: Damage
var state: int = 0

func _init(_game_board: GameBoard, _attacker: Card, _target: Card, _source: Damage):
	super(_game_board)
	attacker = _attacker
	target = _target
	source = _source

func get_priority() -> int:
	return 10

func get_sub_priority() -> int:
	return -state

func get_name() -> String:
	return "Destroy"

func on_start():
	if target.zone == Card.Zone.LOST or target.zone == Card.Zone.JUNK:
		return
	if target.equipped_weapon:
		queue_event(EventDestroy.new(game_board, attacker, target.equipped_weapon, source))
		target.unequip()
	var anim: AnimationMove = AnimationMove.new(target.instance, target.owner.field.get_junk_node().global_position, 30)
	anim.target_scale = Vector2(0.15, 0.15)
	queue_event(EventAnimation.new(game_board, anim))

func on_finish():
	game_board.refresh()

func process(delta):
	if pass_to_child("process", [delta]):
		return
	match state:
		0:
			for e in target.get_effects():
				e.on_destroyed(attacker, source)
				for event in e.get_events():
					queue_event(event)
			for e in attacker.get_effects():
				e.on_destroy(target, source)
				for event in e.get_events():
					queue_event(event)
		1:
			destroy()
		2:
			finish()
	state += 1

func destroy():
	if target.zone == Card.Zone.LOST or target.zone == Card.Zone.JUNK:
		return
	target.owner.field.remove_card(target)
	target.free_instance()
	game_board.refresh()
	target.zone = Card.Zone.JUNK
	target.zone_index = 0
	target.owner.junk.add(target)
