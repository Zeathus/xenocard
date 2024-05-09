class_name Card

enum Type {ANY, BATTLE, EVENT, SITUATION}
enum Attribute {ANY, HUMAN, REALIAN, MACHINE, GNOSIS, MONSTER, BLADE, WEAPON, NOPON, UNKNOWN}
enum Target {ANY, HAND, BALLISTIC, SPREAD, HOMING, NONE}
enum Rarity {COMMON, UNCOMMON, RARE, PROMO}
enum Zone {NONE, DECK, LOST, JUNK, HAND, STANDBY, SITUATION, BATTLEFIELD}

static var scene = preload("res://objects/card.tscn")

static var attribute_icons = {
	Attribute.ANY: preload("res://sprites/attributes/background.png"),
	Attribute.HUMAN: preload("res://sprites/attributes/human.png"),
	Attribute.REALIAN: preload("res://sprites/attributes/realian.png"),
	Attribute.MACHINE: preload("res://sprites/attributes/machine.png"),
	Attribute.GNOSIS: preload("res://sprites/attributes/gnosis.png"),
	Attribute.MONSTER: preload("res://sprites/attributes/monster.png"),
	Attribute.BLADE: preload("res://sprites/attributes/blade.png"),
	Attribute.WEAPON: preload("res://sprites/attributes/weapon.png"),
	Attribute.UNKNOWN: preload("res://sprites/attributes/unknown.png")
}

static var type_backgrounds = {
	Type.BATTLE: preload("res://sprites/card_bg_battle.png"),
	Type.EVENT: preload("res://sprites/card_bg_event.png"),
	Type.SITUATION: preload("res://sprites/card_bg_situation.png")
}

static var rarity_icons = {
	Rarity.COMMON: preload("res://sprites/rarity/rarity_common.png"),
	Rarity.UNCOMMON: preload("res://sprites/rarity/rarity_uncommon.png"),
	Rarity.RARE: preload("res://sprites/rarity/rarity_rare.png"),
	Rarity.PROMO: preload("res://sprites/rarity/rarity_promo.png")
}

static var path: String = "data/cards"
var game: String
var set_name: String
var set_id: int = -1
var id: String
var identifier: String
var name: String
var character: String
var type: Type
var rarity: Rarity
var attribute: Attribute
var hp: int
var max_hp: int
var atk: int
var atk_timer: int
var target: Target
var cost: int
var field: Array[Attribute]
var text: String
var instance: Node2D
var owner: Player
var zone: Zone
var zone_index: int
var e_mark: bool
var downed: bool
var downed_turn: int
var equipped_weapon: Card
var equipped_by: Card
var effect_names: Array[String]
var event_effect_names: Array[String]
var effects: Array[CardEffect]
var event_effects: Array[CardEffect]
var applied_effects: Array[CardEffect]
var turn_count: int
var modify_for_set: Array[Callable] = []

func _init(id: String):
	self.instance = null
	self.zone = Zone.DECK
	self.zone_index = 0
	self.e_mark = false
	self.downed = false
	self.equipped_weapon = null
	self.equipped_by = null
	self.atk_timer = 0
	self.turn_count = 0
	load_json(id)

func reset():
	hp = max_hp
	atk_timer = 0
	e_mark = false
	downed = false
	turn_count = 0
	init_effects(owner.game_board)
	applied_effects.clear()

func load_json(id: String):
	var card_set: String = id.substr(0, id.find("/"))
	self.id = id.substr(len(card_set) + 1)
	var file_name: String = "res://%s/%s/%s.json" % [path, card_set, self.id]
	if FileAccess.file_exists(file_name):
		var file = FileAccess.open(file_name, FileAccess.READ)
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		if error == OK:
			load_data(json.data)
		else:
			push_error("Failed to to parse card file '%s'" % file_name)
	else:
		push_error("Failed to find card file '%s'" % file_name)

func load_data(json):
	self.game = json["game"]
	self.set_name = json["set"]
	self.set_id = json["id"]
	self.name = json["name"]
	if "character" in json:
		self.character = json["character"]
	else:
		self.character = ""
	if "identifier" in json:
		self.identifier = json["identifier"]
	else:
		self.identifier = "%s/%d" % [set_name, set_id]
	self.type = type_from_string(json["type"])
	match json["rarity"]:
		"common":
			self.rarity = Rarity.COMMON
		"uncommon":
			self.rarity = Rarity.UNCOMMON
		"rare":
			self.rarity = Rarity.RARE
		"promo":
			self.rarity = Rarity.PROMO
	self.cost = 0
	self.field = []
	if "requirement" in json:
		if "cost" in json["requirement"]:
			self.cost = json["requirement"]["cost"]
		if "field" in json["requirement"]:
			for i in json["requirement"]["field"]:
				self.field.push_back(attribute_from_string(i))
	if "text" in json:
		self.text = json["text"]
	else:
		self.text = ""
	
	if self.type == Type.BATTLE:
		self.max_hp = json["stats"]["hp"]
		self.hp = self.max_hp
		self.atk = json["stats"]["atk"]
		self.attribute = attribute_from_string(json["stats"]["attribute"])
		self.target = attack_type_from_string(json["stats"]["target"])
	
	self.effect_names = []
	if "effects" in json:
		for i in json["effects"]:
			self.effect_names.push_back(i)

	self.event_effect_names = []
	if "event_effects" in json:
		for i in json["event_effects"]:
			self.event_effect_names.push_back(i)

func init_effects(game_board: GameBoard):
	effects.clear()
	for i in effect_names:
		var param: String = ""
		if "(" in i and ")" in i and i.find("(") < i.rfind(")"):
			param = i.substr(i.find("(") + 1, i.rfind(")") - i.find("(") - 1)
			i = i.substr(0, i.find("("))
		effects.push_back(CardEffect.parse(i).new(game_board, self, param))

	event_effects.clear()
	for i in event_effect_names:
		var param: String = ""
		if "(" in i and ")" in i and i.find("(") < i.rfind(")"):
			param = i.substr(i.find("(") + 1, i.rfind(")") - i.find("(") - 1)
			i = i.substr(0, i.find("("))
		event_effects.push_back(CardEffect.parse(i).new(game_board, self, param))

func validate_effects():
	for i in effect_names:
		var param: String = ""
		if "(" in i and ")" in i and i.find("(") < i.rfind(")"):
			param = i.substr(i.find("(") + 1, i.rfind(")") - i.find("(") - 1)
			i = i.substr(0, i.find("("))
		var effect = CardEffect.parse(i)
		if effect == CardEffect:
			print("Previous error was for the card '%s'" % name)
		else:
			effect.new(null, self, param)

func is_card() -> bool:
	return true

func is_player() -> bool:
	return false

func is_battler() -> bool:
	return self.type == Type.BATTLE and self.attribute != Attribute.WEAPON

func is_equippable() -> bool:
	return self.type == Type.BATTLE and self.attribute == Attribute.WEAPON

func has_stats() -> bool:
	return self.type == Type.BATTLE

func get_resources() -> Array[Attribute]:
	var attr: Array[Attribute] = []
	if self.e_mark:
		return attr
	if self.type == Type.BATTLE:
		attr.push_back(self.attribute)
	return attr

func get_effects() -> Array[CardEffect]:
	var ret: Array[CardEffect] = []
	for e in effects:
		if e.is_active():
			ret.push_back(e)
	for e in applied_effects:
		if e.is_active():
			ret.push_back(e)
	if equipped_weapon:
		ret += equipped_weapon.get_effects()
	var global_effects: Array[CardEffect] = []
	for c in owner.field.get_all_cards() + owner.get_enemy().field.get_all_cards():
		for e in c.get_global_effects():
			if not e.applies_to(self):
				continue
			var global_effect: CardEffect = e.apply_effect(self)
			if not global_effect.is_active():
				continue
			global_effect.set_stackable(c.can_effects_stack())
			var keep: bool = true
			if not global_effect.is_stackable():
				for ge in global_effects:
					if ge.is_stackable():
						continue
					if not ge.host.equals(global_effect.host):
						continue
					if ge.get_script() != global_effect.get_script():
						continue
					keep = false
					break
			if keep:
				global_effects.push_back(global_effect)
	return ret + global_effects

func get_global_effects() -> Array[CardEffect]:
	var ret: Array[CardEffect] = []
	for e in effects:
		if e.is_global() and e.is_active():
			ret.push_back(e)
	return ret

func can_effects_stack() -> bool:
	for e in effects:
		if not e.is_stackable():
			return false
	return true

func has_event_effect() -> bool:
	return not event_effects.is_empty()

func can_activate_event_effect() -> bool:
	if downed or not has_event_effect():
		return false
	for e in event_effects:
		if not e.has_valid_targets():
			return false
	return true

func equals(other: Card) -> bool:
	return identifier == other.identifier

func ignore_unique(card: Card) -> bool:
	for e in get_effects():
		if e.ignore_unique(card):
			return true
	return false

func has_card_conflict(game_board: GameBoard) -> bool:
	for card in owner.game_board.get_all_field_cards():
		if conflicts_with_card(card):
			return true
	return false

func conflicts_with_card(card: Card) -> bool:
	if character != "" and character == card.character and owner == card.owner:
		if not ignore_unique(card):
			return true
	for e in get_effects():
		if e.conflicts_with_card(card):
			return true
	return false

func get_field_requirements() -> Array[Attribute]:
	var ret: Array[Attribute] = self.field
	for e in get_effects():
		ret = e.get_field_requirements(ret)
	return ret

func requirements_met(game_board: GameBoard) -> bool:
	var player: Player = owner
	if player.deck.size() < self.cost:
		return false
	var resources = player.get_resources()
	var any_needed: int = 0
	for attr in get_field_requirements():
		if attr == Attribute.ANY:
			any_needed += 1
			continue
		if resources.find(attr) == -1:
			return false
		resources.erase(attr)
	if len(resources) < any_needed:
		return false
	if has_card_conflict(game_board):
		return false
	for e in get_effects():
		if not e.set_requirements():
			return false
	return true

func uses_one_card_per_turn() -> bool:
	var ret = (type == Type.BATTLE or type == Type.SITUATION)
	for e in get_effects():
		ret = e.uses_one_card_per_turn(ret)
	return ret

func can_move() -> bool:
	for e in get_effects():
		if not e.can_move():
			return false
	return true

func selectable(game_board: GameBoard) -> bool:
	if game_board.get_turn_player() != owner:
		return false
	match game_board.turn_phase:
		GameBoard.Phase.MOVE:
			if self.zone != Zone.STANDBY and self.zone != Zone.BATTLEFIELD:
				return false
			if self.e_mark:
				return false
			if not can_move():
				return false
			return true
		GameBoard.Phase.EVENT:
			if self.type == Type.EVENT:
				if not requirements_met(game_board):
					return false
				if self.zone != Zone.HAND:
					return false
				if self.type != Type.EVENT:
					return false
			else:
				if self.zone != Zone.STANDBY and self.zone != Zone.BATTLEFIELD and self.zone != Zone.SITUATION:
					return false
				if self.e_mark:
					return false
				if not self.has_event_effect():
					return false
				if not self.can_activate_event_effect():
					return false
			return true
		GameBoard.Phase.SET:
			if not requirements_met(game_board):
				return false
			if self.zone != Zone.HAND:
				return false
			if self.type != Type.BATTLE and self.type != Type.SITUATION:
				return false
			if uses_one_card_per_turn():
				if self.type == Type.BATTLE and owner.used_one_battle_card_per_turn:
					return false
				if self.type == Type.SITUATION and owner.used_one_situation_card_per_turn:
					return false
			return true
	return false

func targets_to_select() -> Array[Callable]:
	var ret: Array[Callable] = []
	match owner.game_board.turn_phase:
		GameBoard.Phase.SET:
			for e in get_effects():
				e.targets_to_select_for_set(ret)
	return ret

func can_set_to_battlefield() -> bool:
	for e in get_effects():
		if e.can_set_to_battlefield():
			return true
	return false

func is_valid_zone(new_zone: Zone, index: int) -> bool:
	var ret: bool = true
	if self.zone == Zone.HAND:
		if type == Type.BATTLE and attribute == Attribute.WEAPON:
			if new_zone != Zone.BATTLEFIELD and new_zone != Zone.STANDBY:
				ret = false
		elif type == Type.BATTLE:
			if new_zone == Zone.BATTLEFIELD:
				if not can_set_to_battlefield():
					ret = false
			elif new_zone != Zone.STANDBY:
				ret = false
		elif type == Type.SITUATION:
			if new_zone != Zone.SITUATION:
				ret = false
	elif self.zone == Zone.STANDBY or self.zone == Zone.BATTLEFIELD:
		if new_zone != Zone.STANDBY and new_zone != Zone.BATTLEFIELD:
			ret = false
		if new_zone == Zone.BATTLEFIELD and self.e_mark:
			ret = false
	for e in get_effects():
		ret = e.is_valid_zone(new_zone, index, ret)
	return ret

func can_replace_target() -> bool:
	for e in get_effects():
		if e.can_replace_target():
			return true
	return false

func can_replace_card(card: Card) -> bool:
	for e in get_effects():
		if e.can_replace_card(card):
			return true
	return false

func can_play(game_board: GameBoard, new_zone: Zone, index: int) -> bool:
	if not self.is_valid_zone(new_zone, index):
		return false
	var player: Player = owner
	for e in get_effects():
		if not e.set_requirements():
			return false
	if uses_one_card_per_turn():
		if self.type == Type.BATTLE and owner.used_one_battle_card_per_turn:
			return false
		if self.type == Type.SITUATION and owner.used_one_situation_card_per_turn:
			return false
	var card_in_zone = player.field.get_card(new_zone, index)
	if type == Type.BATTLE and attribute == Attribute.WEAPON:
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
	for e in get_effects():
		if not e.can_equip_weapon(weapon):
			return false
	for e in weapon.get_effects():
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

func can_move_to(game_board: GameBoard, new_zone: Zone, index: int) -> bool:
	if not self.is_valid_zone(new_zone, index):
		return false
	return true

func move(game_board: GameBoard, new_zone: Zone, index: int):
	var player: Player = owner
	player.field.move_card(self, new_zone, index)

func set_e_mark(val: bool):
	self.e_mark = val
	self.instance.set_e_mark(val)

func get_base_atk() -> int:
	if equipped_weapon and equipped_weapon.atk > 0:
		return equipped_weapon.atk
	return atk

func get_atk() -> int:
	var ret = get_base_atk()
	for e in get_effects():
		ret = e.get_atk(ret)
	if ret < 0:
		ret = 0
	return ret

# Opponent is either Card or Player
func get_atk_against(opponent) -> int:
	var ret = get_atk()
	for e in get_effects():
		ret = e.get_atk_against(opponent, ret)
	if ret < 0:
		ret = 0
	return ret

func get_atk_time() -> int:
	if equipped_weapon and equipped_weapon.atk > 0:
		return equipped_weapon.get_atk_time()
	var ret = 1
	for e in get_effects():
		ret = e.get_atk_time(ret)
	return ret

func get_cost() -> int:
	var ret = self.cost
	for e in get_effects():
		ret = e.get_cost(ret)
	return ret

func get_target() -> Target:
	if equipped_weapon and equipped_weapon.target != Target.NONE:
		return equipped_weapon.target
	return self.target

func get_attack_targets(game_board: GameBoard) -> Array:
	var enemy: Player = owner.get_enemy()
	match get_target():
		Target.HAND:
			if self.zone_index >= 2:
				return []
			var opponent = enemy.field.get_card(Zone.BATTLEFIELD, (self.zone_index + 1) % 2)
			if opponent != null and not opponent.evades_attack(self):
				return [opponent]
		Target.BALLISTIC:
			var opponent = enemy.field.get_card(Zone.BATTLEFIELD, (self.zone_index + 1) % 2)
			if opponent != null and not opponent.evades_attack(self):
				return [opponent]
			opponent = enemy.field.get_card(Zone.BATTLEFIELD, (self.zone_index + 1) % 2 + 2)
			if opponent != null and not opponent.evades_attack(self):
				return [opponent]
			return [enemy]
		Target.SPREAD:
			var targets = []
			for opponent in enemy.field.get_battlefield_cards():
				if not opponent.evades_attack(self):
					targets.push_back(opponent)
			return targets
		Target.HOMING:
			return [enemy]
	return []

func penetrates():
	if equipped_weapon and equipped_weapon.target != Target.NONE:
		return equipped_weapon.penetrates()
	if self.target != Target.BALLISTIC:
		return false
	for e in get_effects():
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
	if zone != Zone.BATTLEFIELD:
		return null
	var behind_index = zone_index + 2
	if behind_index > 3:
		return owner
	var behind_card = owner.field.get_card(Zone.BATTLEFIELD, behind_index)
	if behind_card:
		return behind_card
	return owner

func can_attack(game_board: GameBoard) -> bool:
	if downed or zone != Zone.BATTLEFIELD:
		return false
	if get_atk() == 0:
		return false
	return true

func is_destroyed() -> bool:
	return self.hp <= 0

func heal(amount: int):
	self.hp = min(self.max_hp, self.hp + amount)
	owner.game_board.refresh()

func evades_attack(attacker: Card):
	for e in get_effects():
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
	return instance and instance.is_hovering

func set_targeted(val: bool):
	if instance:
		instance.find_child("SelectBorder").visible = val

func set_selectable(val: bool):
	if instance:
		instance.find_child("ValidBorder").visible = val

func on_turn_start():
	turn_count += 1

func can_attack_on_enemy_phase() -> bool:
	for e in get_effects():
		if e.can_attack_on_enemy_phase():
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

static func type_from_string(str: String) -> Type:
	match str.to_lower():
		"battle":
			return Type.BATTLE
		"event":
			return Type.EVENT
		"situation":
			return Type.SITUATION
	return Type.ANY

static func attribute_from_string(str: String) -> Attribute:
	match str.to_lower():
		"any":
			return Attribute.ANY
		"human":
			return Attribute.HUMAN
		"realian":
			return Attribute.REALIAN
		"machine":
			return Attribute.MACHINE
		"gnosis":
			return Attribute.GNOSIS
		"weapon":
			return Attribute.WEAPON
		"monster":
			return Attribute.MONSTER
		"blade":
			return Attribute.BLADE
		"nopon":
			return Attribute.NOPON
		"unknown":
			return Attribute.UNKNOWN
	return Attribute.ANY

static func attack_type_from_string(str: String) -> Target:
	match str.to_lower():
		"hand":
			return Target.HAND
		"ballistic":
			return Target.BALLISTIC
		"spread":
			return Target.SPREAD
		"homing":
			return Target.HOMING
		"none":
			return Target.NONE
	return Target.ANY

static func get_type_name(type: Type) -> String:
	match type:
		Type.BATTLE:
			return "Battle"
		Type.EVENT:
			return "Event"
		Type.SITUATION:
			return "Situation"
	return "N/A"

static func get_target_name(target: Target) -> String:
	match target:
		Target.HAND:
			return "Hand"
		Target.BALLISTIC:
			return "Ballistic"
		Target.SPREAD:
			return "Spread"
		Target.HOMING:
			return "Homing"
		Target.NONE:
			return ""
	return "N/A"

static func get_attribute_icon(attr: Attribute):
	if attr in attribute_icons:
		return attribute_icons[attr]
	return null

static func get_type_background(type: Type):
	if type in type_backgrounds:
		return type_backgrounds[type]
	return null

static func get_rarity_icon(rare: Rarity):
	if rare in rarity_icons:
		return rarity_icons[rare]
	return null
