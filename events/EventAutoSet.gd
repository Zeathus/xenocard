extends Event

class_name EventAutoSet

var player: Player
var to_set: Card
var zone: Enum.Zone
var zone_index: int
var ready_to_finish: bool = false

func _init(_game_board: GameBoard, _player: Player, _to_set: Card, _zone: Enum.Zone, _index: int):
	super(_game_board)
	player = _player
	to_set = _to_set
	zone = _zone
	zone_index = _index

func get_name() -> String:
	return "AutoSet"

func on_start():
	if to_set.zone in [Enum.Zone.STANDBY, Enum.Zone.BATTLEFIELD, Enum.Zone.SITUATION]:
		return
	if to_set.has_card_conflict(game_board):
		return
	play(zone, zone_index)
	var new_pos: Vector2 = to_set.owner.field.get_zone(zone, zone_index).global_position
	if to_set.get_type() == Enum.Type.BATTLE and to_set.get_attribute() == Enum.Attribute.WEAPON:
		if to_set.instance.global_rotation == 0:
			new_pos += Vector2(28, 42)
		else:
			new_pos -= Vector2(28, 42)
	var anim: GameAnimation = AnimationMove.new(to_set.instance, new_pos, 30)
	if to_set.get_type() == Enum.Type.BATTLE and to_set.get_attribute() == Enum.Attribute.WEAPON:
		anim.target_scale = Vector2(0.075, 0.075)
	else:
		anim.target_scale = Vector2(0.15, 0.15)
	anim.set_on_finish(func(): handle_set_effects())
	queue_event(EventAnimation.new(game_board, anim))

func handle_set_effects():
	for e in to_set.get_effects():
		e.on_set()
		for event in e.get_events():
			queue_event(event)
	ready_to_finish = true
	if not has_children():
		finish()

func on_finish():
	pass

func process(delta):
	if pass_to_child("process", [delta]):
		return

func play(new_zone: Enum.Zone, index: int):
	if player.field.get_card(zone, zone_index):
		handle_occupied_zone(zone, zone_index)
	var real_pos: Vector2 = Vector2(0, 0)
	if to_set.zone in [Enum.Zone.DECK, Enum.Zone.LOST, Enum.Zone.JUNK]:
		to_set.instantiate()
		game_board.prepare_card(to_set)
		match to_set.zone:
			Enum.Zone.DECK:
				to_set.owner.deck.erase(to_set)
				real_pos = to_set.owner.field.get_deck_node().global_position
			Enum.Zone.LOST:
				to_set.owner.lost.erase(to_set)
				real_pos = to_set.owner.field.get_lost_node().global_position
			Enum.Zone.JUNK:
				to_set.owner.junk.erase(to_set)
				real_pos = to_set.owner.field.get_junk_node().global_position
	elif to_set.zone == Enum.Zone.HAND:
		real_pos = to_set.instance.global_position
		player.hand.remove(to_set)
	for i in to_set.modify_for_set:
		i.call(to_set)
	to_set.modify_for_set.clear()
	if to_set.get_type() != Enum.Type.BATTLE or to_set.get_attribute() != Enum.Attribute.WEAPON:
		player.field.set_card(to_set, zone, zone_index)
	else:
		player.field.add_card(to_set)
	to_set.instance.global_position = real_pos
	to_set.zone = new_zone
	to_set.zone_index = index

func handle_occupied_zone(zone: Enum.Zone, index: int):
	for e in to_set.get_effects():
		if e.handle_occupied_zone(game_board, zone, index):
			return
	var occupant: Card = player.field.get_card(zone, index)
	if to_set.get_type() == Enum.Type.BATTLE and to_set.get_attribute() == Enum.Attribute.WEAPON:
		if occupant.equipped_weapon != null:
			queue_event(EventDestroy.new(game_board, to_set, occupant.equipped_weapon, Damage.new(Damage.EFFECT | Damage.DISCARD)))
		occupant.equip(to_set)
	else:
		queue_event(EventDestroy.new(game_board, to_set, occupant, Damage.new(Damage.EFFECT | Damage.DISCARD)))
