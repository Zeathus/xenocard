class_name Enum

enum Type {ANY, BATTLE, EVENT, SITUATION}
enum Attribute {ANY, HUMAN, REALIAN, MACHINE, GNOSIS, MONSTER, BLADE, WEAPON, NOPON, UNKNOWN}
enum AttackType {ANY, HAND, BALLISTIC, SPREAD, HOMING, NONE}
enum Rarity {COMMON, UNCOMMON, RARE, PROMO}
enum Zone {NONE, DECK, LOST, JUNK, HAND, STANDBY, SITUATION, BATTLEFIELD}
enum Phase {DRAW, MOVE, EVENT, SET, BLOCK, BATTLE, ADJUST}
enum Trigger {
	NONE,
	PASSIVE,
	DESTROY,
	DESTROYED,
	DISCARDED,
	DAMAGE_TAKEN,
	DAMAGE_DEALT,
	ATTACK_HIT,
	AFTER_ATTACK,
	AFTER_ATTACK_TIMING,
	SET,
	E_MARK_REMOVED,
	ADJUST_PHASE,
	AFTER_NORMAL_DRAW,
	AFTER_MOVE_PHASE,
	TURN_START,
	TURN_END,
	ACTIVATE
}

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

static func type_from_string(str: String) -> Enum.Type:
	str = str.to_upper()
	if str in Enum.Type:
		return Enum.Type[str]
	return Enum.Type.ANY

static func attribute_from_string(str: String) -> Enum.Attribute:
	str = str.to_upper()
	if str in Enum.Attribute:
		return Enum.Attribute[str]
	return Enum.Attribute.ANY

static func attack_type_from_string(str: String) -> Enum.AttackType:
	str = str.to_upper()
	if str in Enum.AttackType:
		return Enum.AttackType[str]
	return Enum.AttackType.ANY

static func get_type_name(type: Type) -> String:
	match type:
		Enum.Type.BATTLE:
			return "Battle"
		Enum.Type.EVENT:
			return "Event"
		Enum.Type.SITUATION:
			return "Situation"
	return "N/A"

static func get_attack_type_name(target: AttackType) -> String:
	match target:
		Enum.AttackType.HAND:
			return "Hand"
		Enum.AttackType.BALLISTIC:
			return "Ballistic"
		Enum.AttackType.SPREAD:
			return "Spread"
		Enum.AttackType.HOMING:
			return "Homing"
		Enum.AttackType.NONE:
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
