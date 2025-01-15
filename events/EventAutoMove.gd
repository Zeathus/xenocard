extends Event

class_name EventAutoMove

var player: Player
var to_move: Card
var zone: Enum.Zone
var zone_index: int
var awaiting_anims: bool = false

func _init(_game_board: GameBoard, _player: Player, _to_move: Card, _zone: Enum.Zone, _zone_index: int):
	super(_game_board)
	player = _player
	to_move = _to_move
	zone = _zone
	zone_index = _zone_index
	start()

func get_name() -> String:
	return "AutoMove"

func on_start():
	broadcast()

func on_finish():
	pass

func process(delta):
	if pass_to_child("process", [delta]):
		return
	if awaiting_anims:
		finish()
	else:
		do_move(player.field, player, zone, zone_index)

func do_move(field: GameField, zone_owner: Player, zone: Enum.Zone, index: int):
	if has_children():
		return
	if zone_owner != player:
		return
	var anims: Array[GameAnimation] = []
	var other_card = field.get_card(zone, index)
	var new_pos: Vector2
	if other_card:
		new_pos = field.get_zone(to_move.zone, to_move.zone_index).global_position
		anims.push_back(AnimationMove.new(other_card.instance, new_pos, 30))
		if other_card.equipped_weapon:
			if other_card.instance.global_rotation == 0:
				new_pos += Vector2(28, 42)
			else:
				new_pos -= Vector2(28, 42)
			anims.push_back(AnimationMove.new(other_card.equipped_weapon.instance, new_pos, 30))
	new_pos = field.get_zone(zone, index).global_position
	anims.push_back(AnimationMove.new(to_move.instance, new_pos, 30))
	if to_move.equipped_weapon:
		if to_move.instance.global_rotation == 0:
			new_pos += Vector2(28, 42)
		else:
			new_pos -= Vector2(28, 42)
		anims.push_back(AnimationMove.new(to_move.equipped_weapon.instance, new_pos, 30))
	to_move.move(game_board, zone, index)
	queue_event(EventAnimations.new(game_board, anims))
	awaiting_anims = true

func broadcast():
	if game_board.is_server():
		for p: Player in [game_board.get_turn_player(), game_board.get_turn_enemy()]:
			var args: Array = [to_move.get_online_id(p.id == 1), str(zone), str(zone_index)]
			p.controller.broadcast_event(get_name(), args)
