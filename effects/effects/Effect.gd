class_name Effect

var game_board: GameBoard
var target: Card
var param: String
var duration: int = -1
var stackable: bool = true
var parent: CardEffect

func _init(_parent: CardEffect, _game_board: GameBoard, _target: Card, param: String = ""):
	self.parent = _parent
	self.game_board = _game_board
	self.target = _target
	self.param = param
	post_init()

func post_init():
	pass

func set_host(_host: Card) -> Effect:
	parent.host = _host
	return self

func is_active() -> bool:
	return not parent.host.downed

func is_global() -> bool:
	return false

func uses_one_card_per_turn(value: bool) -> bool:
	return value

func conflicts_with_card(card: Card) -> bool:
	return false

func targets_to_select_for_effect() -> Array[CardFilter]:
	return []

func targets_to_select_for_set(list: Array[Callable]):
	pass

func has_valid_targets(variables: Dictionary = {}) -> bool:
	return true

func can_replace_target() -> bool:
	return false

func can_replace_card(card: Card) -> bool:
	return false

func effect(variables: Dictionary = {}):
	pass

func handle_effect_targets(targets: Array[Card]):
	pass

func handle_set_targets(targets: Array[Card]):
	pass

func can_set_to_battlefield() -> bool:
	return false

func ignore_unique(card: Card) -> bool:
	return false

func is_valid_zone(new_zone: Enum.Zone, index: int, ret: bool) -> bool:
	return ret

func get_field_requirements(req: Array[Enum.Attribute]) -> Array[Enum.Attribute]:
	return req

func get_cost(cost: int) -> int:
	return cost

func get_max_hp(max_hp: int) -> int:
	return max_hp

func get_atk(atk: int) -> int:
	return atk

func get_atk_against(target, atk: int) -> int:
	return atk

func get_atk_multiplier(multiplier: float) -> float:
	return multiplier

func get_atk_time(time: int) -> int:
	return time

func take_damage(game_board: GameBoard, attacker: Card, damage: int, source: Damage) -> int:
	return damage

func take_set_damage(game_board: GameBoard, attacker: Card, damage: int, source: Damage) -> int:
	return damage

func handle_occupied_zone(game_board: GameBoard, zone: Enum.Zone, index: int) -> bool:
	return false

func can_move_to(new_zone: Enum.Zone, index: int) -> bool:
	return true

func can_move() -> bool:
	return true

func can_equip_weapon(weapon: Card) -> bool:
	return true

func can_attack_on_enemy_phase() -> bool:
	return false

func attack_stopped() -> bool:
	return false

func penetrates():
	return false

func set_requirements():
	return true

func skips_e_mark() -> bool:
	return false

func stops_normal_draw() -> bool:
	return false

func redirects_draw_to_lost(player: Player) -> bool:
	return false

func is_stackable():
	return stackable

func set_stackable(val: bool):
	stackable = val

func reveal_hand(player: Player):
	return false

func skips_phase(phase: Enum.Phase, player: Player):
	return false

func can_end_phase(phase: Enum.Phase, player: Player) -> bool:
	return true

func evades_attack(attacker: Card):
	return false

func equips_to(holder: Card) -> bool:
	return false

func redirect_when_destroyed(attacker: Card, source: Damage) -> Enum.Zone:
	return Enum.Zone.NONE

func get_effect_score(variables: Dictionary = {}) -> int:
	return 0

func get_target_score(target: Card) -> int:
	return 0

static func parse(effect: String) -> Object:
	var effect_script: GDScript = load("res://effects/effects/Effect%s.gd" % effect)
	if effect_script == null:
		Logger.e("Failed to find effect '%s'" % effect)
		return Effect
	return effect_script
