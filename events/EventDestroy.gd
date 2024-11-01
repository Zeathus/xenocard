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
	if target.zone == Enum.Zone.LOST or target.zone == Enum.Zone.JUNK:
		return
	if target.equipped_weapon:
		queue_event(EventDestroy.new(game_board, attacker, target.equipped_weapon, source))
		target.unequip()
	var destination = target.owner.field.get_junk_node()
	for e in target.get_effects(Enum.Trigger.PASSIVE):
		match e.redirect_when_destroyed(attacker, source):
			Enum.Zone.LOST:
				destination = target.owner.field.get_lost_node()
				break
	var anim: AnimationMove = AnimationMove.new(target.instance, destination.global_position, 30)
	anim.target_scale = Vector2(0.15, 0.15)
	queue_event(EventAnimation.new(game_board, anim))

func on_finish():
	game_board.refresh()

func process(delta):
	if pass_to_child("process", [delta]):
		return
	match state:
		0:
			target.trigger_effects(Enum.Trigger.DESTROYED, self, {
				"attacker": attacker,
				"source": source
			})
			attacker.trigger_effects(Enum.Trigger.DESTROY, self, {
				"target": target,
				"source": source
			})
		1:
			destroy()
		2:
			finish()
	state += 1

func destroy():
	if target.zone == Enum.Zone.LOST or target.zone == Enum.Zone.JUNK:
		return
	if target.zone == Enum.Zone.HAND:
		target.owner.hand.remove(target)
	else:
		target.owner.field.remove_card(target)
	target.free_instance()
	game_board.refresh()
	var zone = Enum.Zone.JUNK
	var pile = target.owner.junk
	for e in target.get_effects(Enum.Trigger.PASSIVE):
		match e.redirect_when_destroyed(attacker, source):
			Enum.Zone.LOST:
				zone = Enum.Zone.LOST
				pile = target.owner.lost
				break
	target.zone = zone
	target.zone_index = 0
	pile.add_top(target)
