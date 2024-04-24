extends Event

class_name EventSet

var player: Player
var to_set: Card
var targets: Array[Card]
var targets_required: Array[Callable]

func _init(_game_board: GameBoard, _player: Player, _to_set: Card):
	super(_game_board)
	player = _player
	to_set = _to_set
	targets_required = targets_to_set()
	start()

func get_name() -> String:
	return "Set"

func on_start():
	to_set.select()
	update_valid_zones()

func on_finish():
	to_set.deselect()
	for t in targets:
		t.deselect()
	game_board.hide_valid_zones()

func update_valid_zones():
	game_board.hide_valid_zones()
	if len(targets) < len(targets_required):
		player.field.show_valid_set_targets(targets_required[len(targets)])
	else:
		player.field.show_valid_zones(to_set)

func process(delta):
	if pass_to_child("process", [delta]):
		return

func on_hand_card_selected(hand: GameHand, card: Card):
	if pass_to_child("on_hand_card_selected", [hand, card]):
		return
	if to_set != card:
		blocking = false
	finish()

func on_zone_selected(field: GameField, zone_owner: Player, zone: Card.Zone, index: int):
	if has_children():
		return
	if zone_owner != player:
		return
	var occupant = field.get_card(zone, index)
	if len(targets) < len(targets_required):
		if occupant:
			if occupant in targets:
				occupant.deselect()
				targets.erase(occupant)
				update_valid_zones()
			elif targets_required[len(targets)].call(occupant):
				occupant.select()
				targets.push_back(occupant)
				update_valid_zones()
	elif to_set.can_play(game_board, zone, index):
		play(zone, index)
		for e in to_set.effects:
			e.handle_set_targets(targets)
			for event in e.get_events():
				queue_event(event)
		var new_pos: Vector2 = field.get_zone(zone, index).global_position
		if to_set.type == Card.Type.BATTLE and to_set.attribute == Card.Attribute.WEAPON:
			if to_set.instance.global_rotation == 0:
				new_pos += Vector2(28, 42)
			else:
				new_pos -= Vector2(28, 42)
		var anim: GameAnimation = MoveAnimation.new(to_set.instance, new_pos, 30)
		if to_set.type == Card.Type.BATTLE and to_set.attribute == Card.Attribute.WEAPON:
			anim.target_scale = Vector2(0.075, 0.075)
		else:
			anim.target_scale = Vector2(0.15, 0.15)
		anim.set_on_finish(func(): finish())
		queue_event(EventAnimation.new(game_board, anim))

func play(new_zone: Card.Zone, index: int):
	for i in to_set.modify_for_set:
		i.call(to_set)
	to_set.modify_for_set.clear()
	if to_set.zone == Card.Zone.HAND:
		var real_pos = to_set.instance.global_position
		if player.field.get_card(new_zone, index):
			handle_occupied_zone(new_zone, index)
		player.hand.remove(to_set)
		if to_set.type != Card.Type.BATTLE or to_set.attribute != Card.Attribute.WEAPON:
			player.field.set_card(to_set, new_zone, index)
		else:
			player.field.add_card(to_set)
		to_set.instance.global_position = real_pos
		if to_set.uses_one_card_per_turn():
			player.used_one_card_per_turn = true
		if to_set.type == Card.Type.BATTLE and to_set.attribute != Card.Attribute.WEAPON:
			to_set.set_e_mark(true)
	var cost_paid: int = player.pay_cost(to_set.get_cost())
	for i in range(cost_paid):
		queue_event(EventPayCost.new(game_board, player))
	to_set.zone = new_zone
	to_set.zone_index = index

func handle_occupied_zone(zone: Card.Zone, index: int):
	for e in to_set.get_effects():
		if e.handle_occupied_zone(game_board, zone, index):
			return
	var occupant: Card = player.field.get_card(zone, index)
	if to_set.type == Card.Type.BATTLE and to_set.attribute == Card.Attribute.WEAPON:
		if occupant.equipped_weapon != null:
			queue_event(EventDestroy.new(game_board, to_set, occupant.equipped_weapon, Damage.new(Damage.DISCARD)))
		occupant.equip(to_set)
	else:
		queue_event(EventDestroy.new(game_board, to_set, occupant, Damage.new(Damage.DISCARD)))

func targets_to_set() -> Array[Callable]:
	var ret: Array[Callable] = []
	for e in to_set.get_effects():
		e.targets_to_select_for_set(ret)
	return ret
