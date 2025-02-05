extends Event

class_name EventSet

var player: Player
var to_set: Card
var targets: Array[Card]
var targets_required: Array[Callable]
var ready_to_finish: bool = false
var state: int = 0
var set_zone: Enum.Zone
var set_index: int
var flip: bool = false

func _init(_game_board: GameBoard, _player: Player, _to_set: Card):
	broadcasted = _player.is_online()
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

func handle_set_effects():
	to_set.trigger_effects(Enum.Trigger.SET, self)
	ready_to_finish = true
	if not has_children():
		finish()

func process(delta):
	if pass_to_child("process", [delta]):
		return
	match state:
		1:
			handle_set_targets()
			state = 2
		2:
			prepare_set()
			state = 3
		3:
			if player.field.get_card(set_zone, set_index):
				handle_occupied_zone(set_zone, set_index)
			state = 4
		4:
			flip = to_set.instance.is_face_down()
			play(set_zone, set_index)
			state = 5
		5:
			move_card_to_set()
			state = 6
	if ready_to_finish:
		finish()

func on_hand_card_selected(hand: GameHand, card: Card):
	if pass_to_child("on_hand_card_selected", [hand, card]):
		return
	if state > 0:
		return
	if to_set != card:
		blocking = false
	finish()

func on_zone_selected(field: GameField, zone_owner: Player, zone: Enum.Zone, index: int):
	if has_children():
		return
	if state > 0:
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
		if player.get_enemy().is_online() and not broadcasted:
			var args: Array[String] = [to_set.get_online_id(), str(zone), str(index)]
			for t in targets:
				args.push_back(t.get_online_id())
			player.get_enemy().controller.send_action(Controller.Action.SET, args)
		broadcast_set(zone, index)
		set_zone = zone
		set_index = index
		state = 1

func play(new_zone: Enum.Zone, index: int):
	Logger.i("P%d set %s" % [player.id + 1, to_set.get_name()])
	if to_set.zone == Enum.Zone.HAND:
		var should_set_e_mark = false
		if (to_set.get_type() == Enum.Type.BATTLE and to_set.get_attribute() != Enum.Attribute.WEAPON) or \
			to_set.get_type() == Enum.Type.SITUATION:
			should_set_e_mark = true
			for e in to_set.get_effects(Enum.Trigger.PASSIVE):
				if e.skips_e_mark():
					should_set_e_mark = false
		var cost_to_pay = to_set.get_cost()
		var real_pos = to_set.instance.global_position
		player.hand.remove(to_set)
		if to_set.get_type() != Enum.Type.BATTLE or to_set.get_attribute() != Enum.Attribute.WEAPON:
			player.field.set_card(to_set, new_zone, index)
		else:
			player.field.add_card(to_set)
		to_set.instance.global_position = real_pos
		if to_set.uses_one_card_per_turn():
			if to_set.get_type() == Enum.Type.BATTLE:
				player.used_one_battle_card_per_turn = true
			elif to_set.get_type() == Enum.Type.SITUATION:
				player.used_one_situation_card_per_turn = true
		if should_set_e_mark:
			to_set.set_e_mark(true)
		var cost_paid: int = player.pay_cost(cost_to_pay)
		for i in range(cost_paid):
			queue_event(EventPayCost.new(game_board, player))
	to_set.zone = new_zone
	to_set.zone_index = index
	game_board.refresh()

func handle_set_targets():
	for e in to_set.effects:
		e.handle_set_targets(targets)
		for event in e.get_events():
			queue_event(event)

func prepare_set():
	#if to_set.instance.is_face_down() and to_set.zone == Enum.Zone.HAND:
		#if game_board.online_mode == 0:
			#for i in range(player.hand.size()):
				#if player.hand.cards[i].instance.is_face_down():
					#if player.hand.cards.find(to_set) <= i:
						#break
					#player.hand.cards.erase(to_set)
					#player.hand.cards.insert(i, to_set)
					#player.hand.refresh()
					#break
	for i in to_set.modify_for_set:
		i.call(to_set)
	to_set.modify_for_set.clear()

func handle_occupied_zone(zone: Enum.Zone, index: int):
	for e in to_set.get_effects(Enum.Trigger.PASSIVE):
		if e.handle_occupied_zone(game_board, zone, index):
			return
	var occupant: Card = player.field.get_card(zone, index)
	if to_set.get_type() == Enum.Type.BATTLE and to_set.get_attribute() == Enum.Attribute.WEAPON:
		if occupant.equipped_weapon != null:
			queue_event(EventDestroy.new(game_board, to_set, occupant.equipped_weapon, Damage.new(Damage.DISCARD)))
		occupant.equip(to_set)
	else:
		queue_event(EventDestroy.new(game_board, to_set, occupant, Damage.new(Damage.DISCARD)))

func move_card_to_set():
	var new_pos: Vector2 = player.field.get_zone(set_zone, set_index).global_position
	if to_set.get_type() == Enum.Type.BATTLE and to_set.get_attribute() == Enum.Attribute.WEAPON:
		if to_set.instance.global_rotation == 0:
			new_pos += Vector2(28, 42)
		else:
			new_pos -= Vector2(28, 42)
	if flip:
		to_set.instance.turn_down()
	var anim: GameAnimation = AnimationMove.new(to_set.instance, new_pos, 30, flip)
	if to_set.get_type() == Enum.Type.BATTLE and to_set.get_attribute() == Enum.Attribute.WEAPON:
		anim.target_scale = Vector2(0.075, 0.075)
	else:
		anim.target_scale = Vector2(0.15, 0.15)
	anim.set_on_finish(func():
		handle_set_effects()
		game_board.play_se("cardPlace1")
	)
	queue_event(EventAnimation.new(game_board, anim))

func targets_to_set() -> Array[Callable]:
	var ret: Array[Callable] = []
	for e in to_set.get_effects(Enum.Trigger.PASSIVE):
		e.targets_to_select_for_set(ret)
	return ret

func broadcast_set(zone: Enum.Zone, index: int):
	if game_board.is_server():
		player.get_enemy().controller.send_identity(to_set.get_online_id(player.id == 0), to_set.data.get_full_id())
		var args: Array = [player, to_set.get_online_id(player.id == 0), str(zone), str(index)]
		for t in targets:
			args.push_back(t.get_online_id(player.id == 0))
		player.get_enemy().controller.broadcast_event(get_name(), args)
