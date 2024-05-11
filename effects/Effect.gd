class_name Effect

var game_board: GameBoard
var effect_name: String
var effector: Card
var affected: Card
var events: Array[Event]
var duration: int = -1
var stackable: bool = false

func _init(_game_board: GameBoard, _effector: Card, _affected: Card, _effect: String):
	game_board = _game_board
	effector = _effector
	affected = _affected
	if "(" in _effect and ")" in _effect and _effect.find("(") < _effect.rfind(")"):
		var argv = _effect.substr(_effect.find("(") + 1, _effect.rfind(")") - _effect.find("(") - 1)
		effect_name = _effect.substr(0, _effect.find("("))
		post_init(argv.split(","))
	else:
		effect_name = _effect

static func get_effect_class(_effect: String) -> Object:
	if "(" in _effect:
		_effect = _effect.substr(0, _effect.find("("))
	var effect_script: GDScript = load("res://effects/Effect%s.gd" % _effect)
	if effect_script == null:
		print("Failed to find effect '%s'" % _effect)
		return Effect
	return effect_script

func post_init(argv: Array[String]):
	pass

func set_host(_host: Card) -> Effect:
	effector = _host
	return self

func is_active() -> bool:
	return not effector.downed

func is_global() -> bool:
	return false

func applies_to(target: Card) -> bool:
	return true

func apply_effect(target: Card) -> Effect:
	return null

func uses_one_card_per_turn(value: bool) -> bool:
	return value

func conflicts_with_card(card: Card) -> bool:
	return false

func targets_to_select_for_effect() -> Array[CardFilter]:
	return []

func targets_to_select_for_set(list: Array[Callable]):
	pass

func has_valid_targets() -> bool:
	return true

func can_replace_target() -> bool:
	return false

func can_replace_card(card: Card) -> bool:
	return false

func effect():
	pass

func handle_effect_targets(targets: Array[Card]):
	pass

func handle_set_targets(targets: Array[Card]):
	pass

func can_set_to_battlefield() -> bool:
	return false

func on_set():
	pass

func on_destroyed(attacker: Card, source: Damage):
	pass

func on_destroy(destroyed: Card, source: Damage):
	pass

func ignore_unique(card: Card) -> bool:
	return false

func is_valid_zone(new_zone: int, index: int, ret: bool) -> bool:
	return ret

func get_field_requirements(req: Array[int]) -> Array[int]:
	return req

func get_cost(cost: int) -> int:
	return cost

func get_atk(atk: int) -> int:
	return atk

func get_atk_against(target, atk: int) -> int:
	return atk

func get_atk_time(time: int) -> int:
	return time

func take_damage(game_board: GameBoard, attacker: Card, damage: int, source: Damage) -> int:
	return damage

func take_set_damage(game_board: GameBoard, attacker: Card, damage: int, source: Damage) -> int:
	return damage

func handle_occupied_zone(game_board: GameBoard, zone: int, index: int) -> bool:
	return false

func on_deck_attacked(player: Player):
	pass

func on_target_attacked(target: Card):
	pass

func after_attack(targets):
	pass

func after_attack_turn():
	pass

func on_turn_start():
	pass

func on_turn_start_enemy():
	pass

func adjust():
	pass

func adjust_enemy():
	pass

func can_move_to(new_zone: int, index: int) -> bool:
	return true

func can_move() -> bool:
	return true

func can_equip_weapon(weapon: Card) -> bool:
	return true

func can_attack_on_enemy_phase() -> bool:
	return false

func attack_stopped() -> bool:
	return false

func on_e_mark_removed():
	pass

func penetrates():
	return false

func set_requirements():
	return true

func skips_e_mark() -> bool:
	return false

func after_move_phase():
	pass

func stops_normal_draw() -> bool:
	return false

func after_normal_draw():
	pass

func is_stackable():
	return stackable

func set_stackable(val: bool):
	stackable = val

func reveal_hand(player: Player):
	return false

func skips_phase(phase: GameBoard.Phase, player: Player):
	return false

func evades_attack(attacker: Card):
	return false

func push_event(optional: bool = false):
	events.push_back(EventEffect.new(game_board, self, optional))

func get_events() -> Array[Event]:
	var ret: Array[Event] = events
	events = []
	return ret

func equips_to(holder: Card) -> bool:
	return false

func redirect_when_destroyed(attacker: Card, source: Damage) -> Zone:
	return Zone.NONE

func get_controlling_player() -> Player:
	return effector.owner

func get_confirm_message() -> String:
	return "Activate %s's Effect?" % [effector.name]

func get_help_text() -> String:
	var expanded_text: String = Keyword.expand_keywords(effector.text)
	return expanded_text

func get_user():
	var user: Card = effector
	if user.equipped_by:
		user = user.equipped_by
	return user
