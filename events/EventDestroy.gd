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
	broadcast()
	if target.zone == Enum.Zone.LOST or target.zone == Enum.Zone.JUNK:
		return
	if target.equipped_weapon:
		queue_event(EventDestroy.new(game_board, target.equipped_weapon, target.equipped_weapon, source))
	if target.equipped_by:
		if target.equipped_by.equipped_weapon == target:
			target.equipped_by.unequip()
		target.equipped_by = null
	var destination = target.owner.field.get_junk_node()
	for e in target.get_effects(Enum.Trigger.PASSIVE):
		match e.redirect_when_destroyed(attacker, source):
			Enum.Zone.LOST:
				destination = target.owner.field.get_lost_node()
				break
	var indicator = target.instance.find_child("EffectIndicator")
	if indicator and indicator.visible:
		queue_event(EventAnimation.new(game_board, AnimationEffectEnd.new(target)))
	var anim: AnimationMove = AnimationMove.new(target.instance, destination.global_position, 30)
	anim.keep_in_motion = true
	anim.target_scale = Vector2(0.15, 0.15)
	queue_event(EventAnimation.new(game_board, anim))

func on_finish():
	game_board.refresh()

func process(delta):
	if pass_to_child("process", [delta]):
		return
	match state:
		0:
			if source.destroy():
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
	game_board.refresh()

func broadcast():
	if game_board.is_server():
		for p: Player in [game_board.get_turn_player(), game_board.get_turn_enemy()]:
			p.controller.send_identity(target.get_online_id(p.id == 1), target.data.get_full_id())
			var args: Array = [attacker.get_online_id(p.id == 1), target.get_online_id(p.id == 1), source.get_online_id()]
			p.controller.broadcast_event(get_name(), args)
