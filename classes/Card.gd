class_name Card

static var scene = load("res://objects/card_node.tscn")

static var attribute_icons = {
	Enum.Attribute.ANY: preload("res://sprites/attributes/background.png"),
	Enum.Attribute.HUMAN: preload("res://sprites/attributes/human.png"),
	Enum.Attribute.REALIAN: preload("res://sprites/attributes/realian.png"),
	Enum.Attribute.MACHINE: preload("res://sprites/attributes/machine.png"),
	Enum.Attribute.GNOSIS: preload("res://sprites/attributes/gnosis.png"),
	Enum.Attribute.MONSTER: preload("res://sprites/attributes/monster.png"),
	Enum.Attribute.BLADE: preload("res://sprites/attributes/blade.png"),
	Enum.Attribute.WEAPON: preload("res://sprites/attributes/weapon.png"),
	Enum.Attribute.UNKNOWN: preload("res://sprites/attributes/unknown.png")
}

static var type_backgrounds = {
	Enum.Type.BATTLE: preload("res://sprites/card_bg_battle.png"),
	Enum.Type.EVENT: preload("res://sprites/card_bg_event.png"),
	Enum.Type.SITUATION: preload("res://sprites/card_bg_situation.png")
}

static var rarity_icons = {
	Enum.Rarity.COMMON: preload("res://sprites/rarity/rarity_common.png"),
	Enum.Rarity.UNCOMMON: preload("res://sprites/rarity/rarity_uncommon.png"),
	Enum.Rarity.RARE: preload("res://sprites/rarity/rarity_rare.png"),
	Enum.Rarity.PROMO: preload("res://sprites/rarity/rarity_promo.png")
}

static var path: String = "data/cards"
var data: CardData
var hp: int
var atk_timer: int
var instance: Node2D
var owner: Player
var zone: Enum.Zone
var zone_index: int
var e_mark: bool
var downed: bool
var downed_turn: int
var equipped_weapon: Card
var equipped_by: Card
var effects: Array[CardEffect]
var applied_effects: Array[CardEffect]
var turn_count: int
var modify_for_set: Array[Callable] = []

func _init(_id: String):
	self.data = CardData.get_data(_id)
	self.hp = data.max_hp
	self.instance = null
	self.zone = Enum.Zone.DECK
	self.zone_index = 0
	self.e_mark = false
	self.downed = false
	self.equipped_weapon = null
	self.equipped_by = null
	self.atk_timer = 0
	self.turn_count = 0

func reset():
	hp = data.max_hp
	atk_timer = 0
	e_mark = false
	downed = false
	turn_count = 0
	init_effects(owner.game_board)
	applied_effects.clear()

func init_effects(game_board: GameBoard):
	effects.clear()
	for e in data.effects:
		effects.push_back(e.instantiate(self))

func validate_effects():
	for i in data.effect_names:
		var param: String = ""
		if "(" in i and ")" in i and i.find("(") < i.rfind(")"):
			param = i.substr(i.find("(") + 1, i.rfind(")") - i.find("(") - 1)
			i = i.substr(0, i.find("("))
		var effect = Effect.parse(i)
		if effect == Effect:
			print("Previous error was for the card '%s'" % get_name())
		else:
			effect.new(null, self, param)

func is_card() -> bool:
	return true

func is_player() -> bool:
	return false

func is_battler() -> bool:
	return get_type() == Enum.Type.BATTLE and get_attribute() != Enum.Attribute.WEAPON

func is_equippable() -> bool:
	return get_type() == Enum.Type.BATTLE and get_attribute() == Enum.Attribute.WEAPON

func has_stats() -> bool:
	return get_type() == Enum.Type.BATTLE

func get_resources() -> Array[Enum.Attribute]:
	var attr: Array[Enum.Attribute] = []
	if self.e_mark:
		return attr
	if get_type() == Enum.Type.BATTLE:
		attr.push_back(get_attribute())
	return attr

func get_effects(trigger: Enum.Trigger, variables: Dictionary = {}) -> Array[CardEffect]:
	var ret: Array[CardEffect] = []
	# Check if this is the first player-owned card for non-stackable effects
	var first_of_its_kind: bool = false
	for card in owner.game_board.get_all_field_cards():
		if card == self:
			first_of_its_kind = true
		if card.equals(self) and not card.downed and owner == card.owner:
			break
	# Get all personal effects
	for e in effects:
		if not e.trigger_by(trigger):
			continue
		if e.is_global():
			continue
		if (e.is_stackable() or first_of_its_kind) and e.is_active(variables):
			ret.push_back(e)
	# Get all temporary effects applied from elsewhere
	for e in applied_effects:
		if not e.trigger_by(trigger):
			continue
		if e.is_active(variables):
			ret.push_back(e)
	# Get weapon effects
	if equipped_weapon:
		ret += equipped_weapon.get_effects(trigger)
	# Get globally applied effects
	var global_effects: Array[CardEffect] = []
	for c in owner.field.get_all_cards() + owner.get_enemy().field.get_all_cards():
		for e in c.get_global_effects(trigger, self, variables):
			var keep: bool = true
			if not e.is_stackable():
				for ge in global_effects:
					if ge.is_stackable():
						continue
					if not ge.host.equals(e.host):
						continue
					if ge.host.owner != e.host.owner:
						continue
					keep = false
					break
			if keep:
				global_effects.push_back(e.with_target(self))
	return ret + global_effects

func get_global_effects(trigger: Enum.Trigger, target: Card, variables: Dictionary = {}) -> Array[CardEffect]:
	var ret: Array[CardEffect] = []
	for e in effects:
		if not e.is_global():
			continue
		if not e.trigger_by(trigger):
			continue
		if not e.is_active(variables):
			continue
		if not e.applies_to(target, variables):
			continue
		ret.push_back(e)
	return ret

func can_effects_stack() -> bool:
	for e in effects:
		if not e.is_stackable():
			return false
	return true

func trigger_effects(trigger: Enum.Trigger, event: Event, variables: Dictionary = {}):
	variables["self"] = self
	for e in get_effects(trigger, variables):
		event.queue_event(e.get_event(variables))

func has_event_effect() -> bool:
	return len(get_effects(Enum.Trigger.ACTIVATE)) > 0

func can_activate_event_effect() -> bool:
	if downed or not has_event_effect():
		return false
	for e in get_effects(Enum.Trigger.ACTIVATE):
		if not e.has_valid_targets({"self": self}):
			return false
	return true

func equals(other: Card) -> bool:
	return get_identifier() == other.get_identifier()

func ignore_unique(card: Card) -> bool:
	for e in get_effects(Enum.Trigger.PASSIVE):
		if e.ignore_unique(card):
			return true
	return false

func has_card_conflict(game_board: GameBoard) -> bool:
	for card in owner.game_board.get_all_field_cards():
		if conflicts_with_card(card):
			return true
	return false

func conflicts_with_card(card: Card) -> bool:
	if is_character() and get_character() == card.get_character() and owner == card.owner:
		if not ignore_unique(card):
			return true
	for e in get_effects(Enum.Trigger.PASSIVE):
		if e.conflicts_with_card(card):
			return true
	return false

func get_original_field_requirements() -> Array[Enum.Attribute]:
	return data.field

func get_field_requirements() -> Array[Enum.Attribute]:
	var ret: Array[Enum.Attribute] = get_original_field_requirements()
	for e in get_effects(Enum.Trigger.PASSIVE):
		ret = e.get_field_requirements(ret)
	return ret

func requirements_met(game_board: GameBoard) -> bool:
	var player: Player = owner
	if player.deck.size() < get_cost():
		return false
	var resources = player.get_resources()
	var any_needed: int = 0
	for attr in get_field_requirements():
		if attr == Enum.Attribute.ANY:
			any_needed += 1
			continue
		if resources.find(attr) == -1:
			return false
		resources.erase(attr)
	if len(resources) < any_needed:
		return false
	if has_card_conflict(game_board):
		return false
	for e in get_effects(Enum.Trigger.PASSIVE):
		if not e.set_requirements():
			return false
	return true

func uses_one_card_per_turn() -> bool:
	var type = get_type()
	var ret = (type == Enum.Type.BATTLE or type == Enum.Type.SITUATION)
	for e in get_effects(Enum.Trigger.PASSIVE):
		ret = e.uses_one_card_per_turn(ret)
	return ret

func can_move() -> bool:
	for e in get_effects(Enum.Trigger.PASSIVE):
		if not e.can_move():
			return false
	return true

func selectable(game_board: GameBoard) -> bool:
	if game_board.get_turn_player() != owner:
		return false
	match game_board.turn_phase:
		Enum.Phase.MOVE:
			if self.zone != Enum.Zone.STANDBY and self.zone != Enum.Zone.BATTLEFIELD:
				return false
			if self.e_mark:
				return false
			if not can_move():
				return false
			return true
		Enum.Phase.EVENT, Enum.Phase.BLOCK:
			if get_type() == Enum.Type.EVENT:
				if not requirements_met(game_board):
					return false
				if self.zone != Enum.Zone.HAND:
					return false
				if get_type() != Enum.Type.EVENT:
					return false
			else:
				if self.zone != Enum.Zone.STANDBY and self.zone != Enum.Zone.BATTLEFIELD and self.zone != Enum.Zone.SITUATION:
					return false
				if self.e_mark:
					return false
			if not has_event_effect():
				return false
			if not can_activate_event_effect():
				return false
			return true
		Enum.Phase.SET:
			if not requirements_met(game_board):
				return false
			if self.zone != Enum.Zone.HAND:
				return false
			if get_type() != Enum.Type.BATTLE and get_type() != Enum.Type.SITUATION:
				return false
			if uses_one_card_per_turn():
				if get_type() == Enum.Type.BATTLE and owner.used_one_battle_card_per_turn:
					return false
				if get_type() == Enum.Type.SITUATION and owner.used_one_situation_card_per_turn:
					return false
			return true
	return false

func targets_to_select() -> Array[Callable]:
	var ret: Array[Callable] = []
	match owner.game_board.turn_phase:
		Enum.Phase.SET:
			for e in get_effects(Enum.Trigger.PASSIVE):
				e.targets_to_select_for_set(ret)
	return ret

func can_set_to_battlefield() -> bool:
	for e in get_effects(Enum.Trigger.PASSIVE):
		if e.can_set_to_battlefield():
			return true
	return false

func is_valid_zone(new_zone: Enum.Zone, index: int) -> bool:
	var ret: bool = true
	if self.zone == Enum.Zone.HAND:
		var type = get_type()
		if type == Enum.Type.BATTLE and get_attribute() == Enum.Attribute.WEAPON:
			if new_zone != Enum.Zone.BATTLEFIELD and new_zone != Enum.Zone.STANDBY:
				ret = false
		elif type == Enum.Type.BATTLE:
			if new_zone == Enum.Zone.BATTLEFIELD:
				if not can_set_to_battlefield():
					ret = false
			elif new_zone != Enum.Zone.STANDBY:
				ret = false
		elif type == Enum.Type.SITUATION:
			if new_zone != Enum.Zone.SITUATION:
				ret = false
	elif self.zone == Enum.Zone.STANDBY or self.zone == Enum.Zone.BATTLEFIELD:
		if new_zone != Enum.Zone.STANDBY and new_zone != Enum.Zone.BATTLEFIELD:
			ret = false
		if new_zone == Enum.Zone.BATTLEFIELD and self.e_mark:
			ret = false
	for e in get_effects(Enum.Trigger.PASSIVE):
		ret = e.is_valid_zone(new_zone, index, ret)
	return ret

func can_replace_target() -> bool:
	for e in get_effects(Enum.Trigger.PASSIVE):
		if e.can_replace_target():
			return true
	return false

func can_replace_card(card: Card) -> bool:
	for e in get_effects(Enum.Trigger.PASSIVE):
		if e.can_replace_card(card):
			return true
	return false

func can_play(game_board: GameBoard, new_zone: Enum.Zone, index: int) -> bool:
	if not self.is_valid_zone(new_zone, index):
		return false
	var player: Player = owner
	for e in get_effects(Enum.Trigger.PASSIVE):
		if not e.set_requirements():
			return false
	var type = get_type()
	if uses_one_card_per_turn():
		if type == Enum.Type.BATTLE and owner.used_one_battle_card_per_turn:
			return false
		if type == Enum.Type.SITUATION and owner.used_one_situation_card_per_turn:
			return false
	var card_in_zone = player.field.get_card(new_zone, index)
	if type == Enum.Type.BATTLE and get_attribute() == Enum.Attribute.WEAPON:
		if card_in_zone == null:
			return false
		if not card_in_zone.can_equip(self):
			return false
	elif card_in_zone != null:
		if can_replace_target():
			if not card_in_zone.is_selected():
				return false
		elif not can_replace_card(card_in_zone):
			return false
	return true

func can_equip(weapon: Card):
	for e in get_effects(Enum.Trigger.PASSIVE):
		if not e.can_equip_weapon(weapon):
			return false
	for e in weapon.get_effects(Enum.Trigger.PASSIVE):
		if e.equips_to(self):
			return true
	return false

func equip(weapon: Card):
	atk_timer = 0
	weapon.equipped_by = self
	equipped_weapon = weapon

func unequip():
	atk_timer = 0
	equipped_weapon.equipped_by = null
	equipped_weapon = null

func can_move_to(game_board: GameBoard, new_zone: Enum.Zone, index: int) -> bool:
	if not self.is_valid_zone(new_zone, index):
		return false
	return true

func move(game_board: GameBoard, new_zone: Enum.Zone, index: int):
	var player: Player = owner
	player.field.move_card(self, new_zone, index)

func set_hp(val: int):
	var max_hp = self.get_max_hp()
	if val > max_hp:
		self.hp = max_hp
	else:
		self.hp = val

func set_e_mark(val: bool):
	self.e_mark = val
	self.instance.set_e_mark(val)

func get_game() -> String:
	return data.game

func get_set_name() -> String:
	return data.set_name

func get_set_id() -> int:
	return data.set_id

func get_id() -> String:
	return data.id

func get_identifier() -> String:
	return data.identifier

func get_name() -> String:
	return data.name

func get_character() -> String:
	return data.character

func is_character() -> bool:
	return get_character() != ""

func get_original_type() -> Enum.Type:
	return data.type

func get_type() -> Enum.Type:
	return get_original_type()

func get_rarity() -> Enum.Rarity:
	return data.rarity

func get_original_attribute() -> Enum.Attribute:
	return data.attribute

func get_attribute() -> Enum.Attribute:
	return get_original_attribute()

func get_original_max_hp() -> int:
	return data.max_hp

func get_max_hp() -> int:
	var ret = get_original_max_hp()
	for e in get_effects(Enum.Trigger.PASSIVE):
		ret = e.get_max_hp(ret)
	if ret < 1:
		ret = 1
	if ret < hp:
		hp = ret
	return ret

func get_original_atk() -> int:
	return data.atk

func get_base_atk() -> int:
	if equipped_weapon and equipped_weapon.get_original_atk() > 0:
		return equipped_weapon.get_atk()
	return get_original_atk()

func get_atk() -> int:
	var ret = get_base_atk()
	var multiplier: float = 1.0
	for e in get_effects(Enum.Trigger.PASSIVE):
		ret = e.get_atk(ret)
		multiplier = e.get_atk_multiplier(multiplier)
	if ret < 0:
		ret = 0
	ret *= int(floor(multiplier))
	return ret

# Opponent is either Card or Player
func get_atk_against(opponent) -> int:
	var ret = get_atk()
	for e in get_effects(Enum.Trigger.PASSIVE):
		ret = e.get_atk_against(opponent, ret)
	if ret < 0:
		ret = 0
	return ret

func get_atk_time() -> int:
	if equipped_weapon and equipped_weapon.get_original_atk() > 0:
		return equipped_weapon.get_atk_time()
	var ret = 1
	for e in get_effects(Enum.Trigger.PASSIVE):
		ret = e.get_atk_time(ret)
	return ret

func get_original_cost() -> int:
	return data.cost

func get_cost() -> int:
	var ret = get_original_cost()
	for e in get_effects(Enum.Trigger.PASSIVE):
		ret = e.get_cost(ret)
	return ret

func get_original_attack_type() -> Enum.AttackType:
	return data.attack_type

func get_attack_type() -> Enum.AttackType:
	if equipped_weapon:
		var weapon_type: Enum.AttackType = equipped_weapon.get_attack_type()
		if weapon_type != Enum.AttackType.NONE:
			return weapon_type
	return get_original_attack_type()

func get_attack_targets(game_board: GameBoard) -> Array:
	var enemy: Player = owner.get_enemy()
	match get_attack_type():
		Enum.AttackType.HAND:
			if self.zone_index >= 2:
				return []
			var opponent = enemy.field.get_card(Enum.Zone.BATTLEFIELD, (self.zone_index + 1) % 2)
			if opponent != null and not opponent.evades_attack(self):
				return [opponent]
		Enum.AttackType.BALLISTIC:
			var opponent = enemy.field.get_card(Enum.Zone.BATTLEFIELD, (self.zone_index + 1) % 2)
			if opponent != null and not opponent.evades_attack(self):
				return [opponent]
			opponent = enemy.field.get_card(Enum.Zone.BATTLEFIELD, (self.zone_index + 1) % 2 + 2)
			if opponent != null and not opponent.evades_attack(self):
				return [opponent]
			return [enemy]
		Enum.AttackType.SPREAD:
			var targets = []
			for opponent in enemy.field.get_battlefield_cards():
				if not opponent.evades_attack(self):
					targets.push_back(opponent)
			return targets
		Enum.AttackType.HOMING:
			return [enemy]
	return []

func get_text() -> String:
	return data.text

func get_image() -> Resource:
	return data.get_image()

func penetrates():
	if equipped_weapon and equipped_weapon.get_attack_type() != Enum.AttackType.NONE:
		return equipped_weapon.penetrates()
	if get_attack_type() != Enum.AttackType.BALLISTIC:
		return false
	for e in get_effects(Enum.Trigger.PASSIVE):
		if e.penetrates():
			return true
	return false

func down(cause: Card):
	self.downed = true
	self.downed_turn = turn_count
	self.instance.set_downed(self.downed)

func undown():
	self.downed = false
	self.instance.set_downed(self.downed)

func get_behind():
	if zone != Enum.Zone.BATTLEFIELD:
		return null
	var behind_index = zone_index + 2
	if behind_index > 3:
		return owner
	var behind_card = owner.field.get_card(Enum.Zone.BATTLEFIELD, behind_index)
	if behind_card:
		return behind_card
	return owner

func can_attack(game_board: GameBoard) -> bool:
	if downed or zone != Enum.Zone.BATTLEFIELD:
		return false
	if get_atk() == 0:
		return false
	return true

func is_destroyed() -> bool:
	return self.hp <= 0

func heal(amount: int):
	self.hp = min(get_max_hp(), self.hp + amount)
	owner.game_board.refresh()

func evades_attack(attacker: Card):
	for e in get_effects(Enum.Trigger.PASSIVE):
		if e.evades_attack(attacker):
			return true
	return false

func select():
	if instance:
		instance.find_child("SelectBorder").visible = true

func deselect():
	if instance:
		instance.find_child("SelectBorder").visible = false

func is_selected():
	if instance == null:
		return false
	var border = instance.find_child("SelectBorder")
	return border and border.visible

func is_hovered():
	return instance and instance.is_hovering()

func set_targeted(val: bool):
	if instance:
		instance.find_child("SelectBorder").visible = val

func set_selectable(val: bool):
	if instance:
		instance.find_child("ValidBorder").visible = val

func set_help_text(text: String):
	if instance:
		instance.set_help_text(text)

func hide_help_text():
	if instance:
		instance.hide_help_text()

func on_turn_start(is_enemy: bool = true):
	turn_count += 1

func can_attack_on_enemy_phase() -> bool:
	for e in get_effects(Enum.Trigger.PASSIVE):
		if e.can_attack_on_enemy_phase():
			return true
	return false

func is_deployable() -> bool:
	if zone != Enum.Zone.STANDBY:
		return false
	if not can_move():
		return false
	for i in range(4):
		if can_move_to(owner.game_board, Enum.Zone.BATTLEFIELD, i):
			return true
	return false

func instantiate() -> Node2D:
	if self.instance:
		return self.instance
	self.instance = scene.instantiate()
	self.instance.load_card(self)
	self.instance.global_scale = Vector2(0.15, 0.15)
	if self.owner.show_hand or self.owner.reveal_hand:
		self.instance.turn_up()
	else:
		self.instance.turn_down()
	return instance

func free_instance():
	if self.instance:
		self.instance.queue_free()
		self.instance = null
