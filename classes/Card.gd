class_name Card

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
var type: int
var rarity: int
var attribute: int
var hp: int
var max_hp: int
var atk: int
var atk_timer: int
var target: int
var cost: int
var field: Array[int]
var text: String
var instance: Node2D
var owner: Player
var zone: int
var zone_index: int
var e_mark: bool
var downed: bool
var downed_turn: int
var equipped_weapon: Card
var equipped_by: Card
var effect_data: Dictionary
var effects: Dictionary
var event_effects: Array[Effect]
var applied_effects: Array[Effect]
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

func init_effects(game_board: GameBoard):
	effects.clear()
	for trigger in effect_data:
		var trigger_effects: Array[CardEffect] = []
		for effect in effect_data[trigger]:
			trigger_effects.push_back(CardEffect.new(game_board, self, effect))
		effects[trigger] = trigger_effects
		#var param: String = ""
		#if "(" in i and ")" in i and i.find("(") < i.rfind(")"):
			#param = i.substr(i.find("(") + 1, i.rfind(")") - i.find("(") - 1)
			#i = i.substr(0, i.find("("))
		#effects.push_back(Effect.parse(i).new(game_board, self, param))

func validate_effects():
	pass
	#for i in effect_names:
		#var param: String = ""
		#if "(" in i and ")" in i and i.find("(") < i.rfind(")"):
			#param = i.substr(i.find("(") + 1, i.rfind(")") - i.find("(") - 1)
			#i = i.substr(0, i.find("("))
		#var effect = Effect.parse(i)
		#if effect == Effect:
			#print("Previous error was for the card '%s'" % name)
		#else:
			#effect.new(null, self, param)

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

func get_resources() -> Array[int]:
	var attr: Array[int] = []
	if self.e_mark:
		return attr
	if self.type == Type.BATTLE:
		attr.push_back(self.attribute)
	return attr

func get_effects(trigger: Trigger = CardEffect.Trigger.PASSIVE) -> Array[CardEffect]:
	var ret: Array[CardEffect] = []
	#var stackable: bool = true
	#if not can_effects_stack():
		#for card in owner.game_board.get_all_field_cards():
			#if card == self:
				#break
			#if card.equals(self) and not card.e_mark and not card.downed:
				#stackable = false
				#break
	for e in effects[trigger]:
		#e.set_stackable(stackable)
		if e.is_stackable() and e.is_active():
			ret.push_back(e)
	#for e in applied_effects:
		#if e.is_active():
			#ret.push_back(e)
	if equipped_weapon:
		ret += equipped_weapon.get_effects(trigger)
	#var global_effects: Array[Effect] = []
	#for c in owner.field.get_all_cards() + owner.get_enemy().field.get_all_cards():
		#for e in c.get_global_effects():
			#if not e.applies_to(self):
				#continue
			#var global_effect: Effect = e.apply_effect(self)
			#if not global_effect.is_active():
				#continue
			#global_effect.set_stackable(c.can_effects_stack())
			#var keep: bool = true
			#if not global_effect.is_stackable():
				#for ge in global_effects:
					#if ge.is_stackable():
						#continue
					#if not ge.host.equals(global_effect.host):
						#continue
					#if ge.get_script() != global_effect.get_script():
						#continue
					#keep = false
					#break
			#if keep:
				#global_effects.push_back(global_effect)
	return ret #+ global_effects

func get_global_effects() -> Array[Effect]:
	var ret: Array[Effect] = []
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
	return get_effects().any(func(e): e.ignore_unique(card))

func has_card_conflict(game_board: GameBoard) -> bool:
	for card in owner.game_board.get_all_field_cards():
		if conflicts_with_card(card):
			return true
	return false

func conflicts_with_card(card: Card) -> bool:
	if character != "" and character == card.character and owner == card.owner:
		if not ignore_unique(card):
			return true
	if get_effects().any(func(e): e.conflicts_with_card(card)):
		return true
	return false

func get_field_requirements() -> Array[int]:
	var ret: Array[int] = self.field
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
		GameBoard.Phase.EVENT, GameBoard.Phase.BLOCK:
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

func is_valid_zone(new_zone: int, index: int) -> bool:
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

func can_play(game_board: GameBoard, new_zone: int, index: int) -> bool:
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

func can_move_to(game_board: GameBoard, new_zone: int, index: int) -> bool:
	if not self.is_valid_zone(new_zone, index):
		return false
	return true

func move(game_board: GameBoard, new_zone: int, index: int):
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

func get_target() -> AttackType:
	if equipped_weapon and equipped_weapon.target != AttackType.NONE:
		return equipped_weapon.target
	return self.target

func get_attack_targets(game_board: GameBoard) -> Array:
	var enemy: Player = owner.get_enemy()
	match get_target():
		AttackType.HAND:
			if self.zone_index >= 2:
				return []
			var opponent = enemy.field.get_card(Zone.BATTLEFIELD, (self.zone_index + 1) % 2)
			if opponent != null and not opponent.evades_attack(self):
				return [opponent]
		AttackType.BALLISTIC:
			var opponent = enemy.field.get_card(Zone.BATTLEFIELD, (self.zone_index + 1) % 2)
			if opponent != null and not opponent.evades_attack(self):
				return [opponent]
			opponent = enemy.field.get_card(Zone.BATTLEFIELD, (self.zone_index + 1) % 2 + 2)
			if opponent != null and not opponent.evades_attack(self):
				return [opponent]
			return [enemy]
		AttackType.SPREAD:
			var targets = []
			for opponent in enemy.field.get_battlefield_cards():
				if not opponent.evades_attack(self):
					targets.push_back(opponent)
			return targets
		AttackType.HOMING:
			return [enemy]
	return []

func penetrates():
	if equipped_weapon and equipped_weapon.target != AttackType.NONE:
		return equipped_weapon.penetrates()
	if self.target != AttackType.BALLISTIC:
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
