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
	ATTACK_HIT,
	DECK_HIT,
	AFTER_ATTACK,
	AFTER_ATTACK_TIMING,
	SET,
	E_MARK_REMOVED,
	ADJUST_PHASE,
	ADJUST_PHASE_PLAYER,
	ADJUST_PHASE_ENEMY,
	AFTER_NORMAL_DRAW,
	AFTER_NORMAL_DRAW_PLAYER,
	AFTER_NORMAL_DRAW_ENEMY,
	AFTER_MOVE_PHASE,
	TURN_START,
	TURN_START_PLAYER,
	TURN_START_ENEMY,
	TURN_END,
	ACTIVATE,
	COUNTER
}
enum GameResult {
	NONE = 0,
	TIE = 1,
	P1_WIN = 2,
	P2_WIN = 3,
	P1_FORFEIT = 4,
	P2_FORFEIT = 5,
	CANCELLED = 6,
	TUTORIAL = 7,
}

static var obj: Object = Object.new()

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

static func type_from_string(value: String) -> Enum.Type:
	value = value.to_upper()
	if value in Enum.Type:
		return Enum.Type[value]
	return Enum.Type.ANY

static func attribute_from_string(value: String) -> Enum.Attribute:
	value = value.to_upper()
	if value in Enum.Attribute:
		return Enum.Attribute[value]
	return Enum.Attribute.ANY

static func get_attribute_name(attribute: Attribute) -> String:
	match attribute:
		Enum.Attribute.ANY:
			return "Any"
		Enum.Attribute.HUMAN:
			return "Human"
		Enum.Attribute.REALIAN:
			return "Realian"
		Enum.Attribute.MACHINE:
			return "Machine"
		Enum.Attribute.GNOSIS:
			return "Gnosis"
		Enum.Attribute.MONSTER:
			return "Monster"
		Enum.Attribute.BLADE:
			return "Blade"
		Enum.Attribute.WEAPON:
			return "Weapon"
		Enum.Attribute.NOPON:
			return "Nopon"
		Enum.Attribute.UNKNOWN:
			return "Unknown"
	return "N/A"

static func attack_type_from_string(value: String) -> Enum.AttackType:
	value = value.to_upper()
	if value in Enum.AttackType:
		return Enum.AttackType[value]
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
			return obj.tr("ATTACK_TYPE_HAND")
		Enum.AttackType.BALLISTIC:
			return obj.tr("ATTACK_TYPE_BALLISTIC")
		Enum.AttackType.SPREAD:
			return obj.tr("ATTACK_TYPE_SPREAD")
		Enum.AttackType.HOMING:
			return obj.tr("ATTACK_TYPE_HOMING")
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
