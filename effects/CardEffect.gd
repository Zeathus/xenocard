class_name CardEffect

var trigger: Enum.Trigger
var requirements: Array[Requirement]
var effects: Array[Effect]
var host: Card
var ignores_down: bool
var global: bool
var optional: bool
var stackable: bool
var animated: bool
var duration: int
var events: Array[Event]
var applied_effect: EffectData

func _init(_trigger: Enum.Trigger, _host: Card):
	trigger = _trigger
	host = _host
	requirements = []
	effects = []
	ignores_down = false
	global = false
	optional = false
	stackable = true
	animated = true
	duration = -1

func set_host(_host: Card) -> CardEffect:
	host = _host
	return self

func trigger_by(t: Enum.Trigger):
	return trigger == t

func is_active() -> bool:
	for r in requirements:
		if not r.met():
			return false
	return (ignores_down or not host.downed)

func is_global() -> bool:
	return global

func applies_to(target: Card) -> bool:
	return true

func apply_effect(target: Card) -> Effect:
	return null

func uses_one_card_per_turn(value: bool) -> bool:
	for e in effects:
		value = e.uses_one_card_per_turn(value)
	return value

func conflicts_with_card(card: Card) -> bool:
	for e in effects:
		if e.conflicts_with_card(card):
			return true
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

func effect(variables: Dictionary = {}):
	for e in effects:
		e.effect(variables)

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

func is_valid_zone(new_zone: Enum.Zone, index: int, ret: bool) -> bool:
	return ret

func get_field_requirements(req: Array[Enum.Attribute]) -> Array[Enum.Attribute]:
	return req

func get_cost(cost: int) -> int:
	return cost

func get_atk(atk: int) -> int:
	for e in effects:
		atk = e.get_atk(atk)
	return atk

func get_atk_against(target, atk: int) -> int:
	for e in effects:
		atk = e.get_atk_against(target, atk)
	return atk

func get_atk_time(time: int) -> int:
	for e in effects:
		time = e.get_atk_time(time)
	return time

func take_damage(game_board: GameBoard, attacker: Card, damage: int, source: Damage) -> int:
	return damage

func take_set_damage(game_board: GameBoard, attacker: Card, damage: int, source: Damage) -> int:
	return damage

func handle_occupied_zone(game_board: GameBoard, zone: Enum.Zone, index: int) -> bool:
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

func on_e_mark_removed():
	pass

func penetrates():
	for e in effects:
		if e.penetrates():
			return true
	return false

func set_requirements():
	return true

func skips_e_mark() -> bool:
	return false

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

func skips_phase(phase: Enum.Phase, player: Player):
	return false

func evades_attack(attacker: Card):
	return false

func push_event(variables: Dictionary = {}):
	events.push_back(get_event(variables))

func get_event(variables: Dictionary = {}):
	var event = EventEffect.new(get_game_board(), self, variables, optional)
	event.animate = animated
	return event

func get_game_board() -> GameBoard:
	return host.owner.game_board

func get_events() -> Array[Event]:
	var ret: Array[Event] = events
	events = []
	return ret

func equips_to(holder: Card) -> bool:
	for e in effects:
		if e.equips_to(holder):
			return true
	return false

func redirect_when_destroyed(attacker: Card, source: Damage) -> Enum.Zone:
	return Enum.Zone.NONE

func get_controlling_player() -> Player:
	return host.owner

func get_confirm_message() -> String:
	return "Activate %s's Effect?" % [host.get_name()]

func get_help_text() -> String:
	var expanded_text: String = Keyword.expand_keywords(host.get_text())
	return expanded_text

func get_user():
	var user: Card = host
	if user.equipped_by:
		user = user.equipped_by
	return user
