class_name CardEffect

var game_board: GameBoard
var card: Card
var global_target: Card
var param: String
var events: Array[Event]
var host: Card = null

func _init(game_board: GameBoard, card: Card, param: String = ""):
	self.game_board = game_board
	self.card = card
	self.global_target = null
	self.param = param
	post_init()

func post_init():
	pass

func set_host(_host: Card) -> CardEffect:
	host = _host
	return self

func is_active() -> bool:
	if host:
		return not host.downed
	return not card.downed

func is_global() -> bool:
	return false

func applies_to(target: Card) -> bool:
	return true

func apply_effect(target: Card) -> CardEffect:
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

func handle_effect_targets(targets: Array[Card]):
	pass

func handle_set_targets(targets: Array[Card]):
	pass

func can_set_to_battlefield() -> bool:
	return false

func on_destroyed(attacker: Card, source: Damage):
	pass

func on_destroy(destroyed: Card, source: Damage):
	pass

func ignore_unique(card: Card) -> bool:
	return false

func is_valid_zone(new_zone: Card.Zone, index: int, ret: bool) -> bool:
	return ret

func get_field_requirements(req: Array[Card.Attribute]) -> Array[Card.Attribute]:
	return req

func get_cost(cost: int) -> int:
	return cost

func get_atk(target, atk: int) -> int:
	return atk

func get_atk_time(time: int) -> int:
	return time

func take_damage(game_board: GameBoard, attacker: Card, damage: int, source: Damage) -> int:
	return damage

func handle_occupied_zone(game_board: GameBoard, zone: Card.Zone, index: int) -> bool:
	return false

func on_deck_attacked(player: Player):
	pass

func on_target_attacked(target: Card):
	pass

func after_attack_hit(targets):
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

func can_move_to(new_zone: Card.Zone, index: int) -> bool:
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

func effect():
	pass

func get_game_board() -> GameBoard:
	return card.owner.game_board

func get_events() -> Array[Event]:
	var ret: Array[Event] = events
	events = []
	return ret

func equips_to(holder: Card) -> bool:
	return false

func get_confirm_message() -> String:
	return "Activate %s's Effect?" % [card.name]

func get_help_text() -> String:
	var expanded_text: String = Keyword.expand_keywords(card.text)
	return expanded_text

func get_user():
	var user: Card = card
	if user.equipped_by:
		user = user.equipped_by
	return user

static func parse(effect: String) -> Object:
	var effect_script: GDScript = load("res://effects/Effect%s.gd" % effect)
	if effect_script == null:
		print("Failed to find effect '%s'" % effect)
		return CardEffect
	return effect_script
