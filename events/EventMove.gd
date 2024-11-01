extends Event

class_name EventMove

var player: Player
var to_move: Card
var awaiting_anims: bool = false

func _init(_game_board: GameBoard, _player: Player, _to_move: Card):
	super(_game_board)
	player = _player
	to_move = _to_move
	start()

func get_name() -> String:
	return "Move"

func on_start():
	to_move.select()
	player.field.show_valid_zones(to_move)

func on_finish():
	to_move.deselect()
	game_board.hide_valid_zones()

func process(delta):
	if pass_to_child("process", [delta]):
		return
	if awaiting_anims:
		finish()

func on_zone_selected(field: GameField, zone_owner: Player, zone: Enum.Zone, index: int):
	if has_children():
		return
	if zone_owner != player:
		return
	if to_move.can_move_to(game_board, zone, index):
		var anims: Array[GameAnimation] = []
		var other_card = field.get_card(zone, index)
		if other_card:
			if not (other_card.can_move() and other_card.can_move_to(game_board, to_move.zone, to_move.zone_index)):
				return
			var new_pos = field.get_zone(to_move.zone, to_move.zone_index).global_position
			anims.push_back(AnimationMove.new(other_card.instance, new_pos, 30))
			if other_card.equipped_weapon:
				if other_card.instance.global_rotation == 0:
					new_pos += Vector2(28, 42)
				else:
					new_pos -= Vector2(28, 42)
				anims.push_back(AnimationMove.new(other_card.equipped_weapon.instance, new_pos, 30))
		var new_pos = field.get_zone(zone, index).global_position
		anims.push_back(AnimationMove.new(to_move.instance, new_pos, 30))
		if to_move.equipped_weapon:
			if to_move.instance.global_rotation == 0:
				new_pos += Vector2(28, 42)
			else:
				new_pos -= Vector2(28, 42)
			anims.push_back(AnimationMove.new(to_move.equipped_weapon.instance, new_pos, 30))
		to_move.move(game_board, zone, index)
		queue_event(EventAnimations.new(game_board, anims))
		game_board.hide_valid_zones()
		awaiting_anims = true
