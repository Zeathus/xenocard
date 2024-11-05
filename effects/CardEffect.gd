class_name CardEffect

var trigger: Enum.Trigger
var requirements: Array[Requirement]
var effects: Array[Effect]
var host: Card
var ignores_down: bool
var global: CardFilter
var optional: bool
var stackable: bool
var animated: bool
var duration: int
var events: Array[Event]
var applied_effect: EffectData
var effects_on_end: Array[Effect]

func _init(_trigger: Enum.Trigger, _host: Card):
	trigger = _trigger
	host = _host
	requirements = []
	effects = []
	ignores_down = false
	global = null
	optional = false
	stackable = true
	animated = true
	duration = -1
	effects_on_end = []

func set_host(_host: Card) -> CardEffect:
	host = _host
	return self

func trigger_by(t: Enum.Trigger):
	return trigger == t

func is_active(variables: Dictionary = {}) -> bool:
	for r in requirements:
		if not r.met(variables):
			return false
	return (ignores_down or not host.downed)

func is_global() -> bool:
	return global != null

func applies_to(target: Card, variables: Dictionary = {}) -> bool:
	if not is_global():
		return false
	return global.is_valid(host.owner, target, variables)

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
	var targets: Array[CardFilter] = []
	for e in effects:
		for t in e.targets_to_select_for_effect():
			targets.push_back(t)
	return targets

func targets_to_select_for_set(list: Array[Callable]):
	for e in effects:
		# Adds callables to the list
		e.targets_to_select_for_set(list)

func has_valid_targets(variables: Dictionary = {}) -> bool:
	for e in effects:
		if not e.has_valid_targets(variables):
			return false
	return true

func can_replace_target() -> bool:
	for e in effects:
		if e.can_replace_target():
			return true
	return false

func can_replace_card(card: Card) -> bool:
	for e in effects:
		if e.can_replace_card(card):
			return true
	return false

func effect(variables: Dictionary = {}):
	for e in effects:
		e.effect(variables)

func effect_with_targets(targets: Array[Card], variables: Dictionary = {}):
	var target_idx = 0
	for e in effects:
		var targets_for_effect = len(e.targets_to_select_for_effect())
		if targets_for_effect > 0:
			if target_idx + targets_for_effect > len(targets):
				print("Not enough targets for effect")
				return
			var eff_targets = targets.slice(target_idx, target_idx + targets_for_effect)
			var eff_variables = {
				"effect_targets": eff_targets,
				"all_effect_targets": targets
			}
			eff_variables.merge(variables)
			e.effect(eff_variables)
			target_idx += targets_for_effect
		else:
			e.effect(variables)

func handle_set_targets(targets: Array[Card]):
	for e in effects:
		e.handle_set_targets(targets)

func can_set_to_battlefield() -> bool:
	for e in effects:
		if e.can_set_to_battlefield():
			return true
	return false

func on_set():
	pass

func on_destroyed(attacker: Card, source: Damage):
	pass

func on_destroy(destroyed: Card, source: Damage):
	pass

func ignore_unique(card: Card) -> bool:
	for e in effects:
		if e.ignore_unique(card):
			return true
	return false

func is_valid_zone(new_zone: Enum.Zone, index: int, ret: bool) -> bool:
	for e in effects:
		ret = e.is_valid_zone(new_zone, index, ret)
	return ret

func get_field_requirements(req: Array[Enum.Attribute]) -> Array[Enum.Attribute]:
	for e in effects:
		req = e.get_field_requirements(req)
	return req

func get_cost(cost: int) -> int:
	for e in effects:
		cost = e.get_cost(cost)
	return cost

func get_max_hp(max_hp: int) -> int:
	for e in effects:
		max_hp = e.get_max_hp(max_hp)
	return max_hp

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
	for e in effects:
		damage = e.take_damage(game_board, attacker, damage, source)
	return damage

func take_set_damage(game_board: GameBoard, attacker: Card, damage: int, source: Damage) -> int:
	for e in effects:
		damage = e.take_set_damage(game_board, attacker, damage, source)
	return damage

func handle_occupied_zone(game_board: GameBoard, zone: Enum.Zone, index: int) -> bool:
	for e in effects:
		if e.handle_occupied_zone(game_board, zone, index):
			return true
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
	for e in effects:
		if not e.can_move_to(new_zone, index):
			return false
	return true

func can_move() -> bool:
	for e in effects:
		if not e.can_move():
			return false
	return true

func can_equip_weapon(weapon: Card) -> bool:
	for e in effects:
		if not e.can_equip_weapon(weapon):
			return false
	return true

func can_attack_on_enemy_phase() -> bool:
	for e in effects:
		if e.can_attack_on_enemy_phase():
			return true
	return false

func attack_stopped() -> bool:
	for e in effects:
		if e.attack_stopped():
			return true
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
	for e in effects:
		if e.skips_e_mark():
			return true
	return false

func stops_normal_draw() -> bool:
	for e in effects:
		if e.stops_normal_draw():
			return true
	return false

func redirects_draw_to_lost(player: Player) -> bool:
	for e in effects:
		if e.redirects_draw_to_lost(player):
			return true
	return false

func after_normal_draw():
	pass

func is_stackable():
	return stackable

func set_stackable(val: bool):
	stackable = val

func reveal_hand(player: Player):
	for e in effects:
		if e.reveal_hand(player):
			return true
	return false

func skips_phase(phase: Enum.Phase, player: Player):
	for e in effects:
		if e.skips_phase(phase, player):
			return true
	return false

func can_end_phase(phase: Enum.Phase, player: Player) -> bool:
	for e in effects:
		if not e.can_end_phase(phase, player):
			return false
	return true

func evades_attack(attacker: Card):
	for e in effects:
		if e.evades_attack(attacker):
			return true
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
	for e in effects:
		var redirect = e.redirect_when_destroyed(attacker, source)
		if redirect != Enum.Zone.NONE:
			return redirect
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

func with_target(card: Card) -> CardEffect:
	var copy = CardEffect.new(trigger, host)
	copy.optional = optional
	copy.stackable = stackable
	copy.animated = animated
	for e in effects:
		copy.effects.push_back(e.get_script().new(copy, get_game_board(), card, e.param))
	return copy
