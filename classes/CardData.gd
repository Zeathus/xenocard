class_name CardData

static var data: Array[CardData]
static var path: String = "res://data/cards"

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

func _init(_id: String):
	var json = get_json(_id)
	if not json.is_empty():
		load_json(json)

static func load_cards():
	data = []
	var dir = DirAccess.open(path)
	if not dir:
		print("Failed to find card directory.")
		return
	dir.list_dir_begin()
	var set_name = dir.get_next()
	while set_name != "":
		if not dir.current_is_dir():
			set_name = dir.get_next()
			continue
		var sub_dir = DirAccess.open("res://data/cards/%s" % set_name)
		sub_dir.list_dir_begin()
		var card_file = sub_dir.get_next()
		while card_file != "":
			card_file = card_file.substr(0, card_file.find(".json"))
			var card = CardData.new("%s/%s" % [set_name, card_file])
			data.push_back(card)
			card_file = sub_dir.get_next()
		set_name = dir.get_next()
		sub_dir.list_dir_end()
	dir.list_dir_end()

func get_json(_id: String) -> Dictionary:
	var card_set: String = id.substr(0, id.find("/"))
	id = _id.substr(len(card_set) + 1)
	var file_name: String = "res://%s/%s/%s.json" % [path, card_set, id]
	if FileAccess.file_exists(file_name):
		var file = FileAccess.open(file_name, FileAccess.READ)
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		if error == OK:
			return json.data
		else:
			push_error("Failed to to parse card file '%s'" % file_name)
	else:
		push_error("Failed to find card file '%s'" % file_name)
	return {}

func load_json(json: Dictionary):
	game = json["game"]
	set_name = json["set"]
	set_id = json["id"]
	name = json["name"]
	if "character" in json:
		character = json["character"]
	else:
		character = ""
	if "identifier" in json:
		identifier = json["identifier"]
	else:
		identifier = "%s/%d" % [set_name, set_id]
	type = type_from_string(json["type"])
	match json["rarity"]:
		"common":
			rarity = Rarity.COMMON
		"uncommon":
			rarity = Rarity.UNCOMMON
		"rare":
			rarity = Rarity.RARE
		"promo":
			rarity = Rarity.PROMO
	cost = 0
	field = []
	if "requirement" in json:
		if "cost" in json["requirement"]:
			cost = json["requirement"]["cost"]
		if "field" in json["requirement"]:
			for i in json["requirement"]["field"]:
				field.push_back(attribute_from_string(i))
	if "text" in json:
		text = json["text"]
	else:
		text = ""
	
	if type == Type.BATTLE:
		max_hp = json["stats"]["hp"]
		hp = max_hp
		atk = json["stats"]["atk"]
		attribute = attribute_from_string(json["stats"]["attribute"])
		target = attack_type_from_string(json["stats"]["target"])
	
	if "effects" in json:
		if json["effects"] is Dictionary:
			effect_data = {}
			for trigger in json["effects"]:
				if not trigger.to_upper() in CardEffect.Trigger:
					print("Invalid effect Trigger: '%s'" % trigger)
					continue
				effect_data[CardEffect.Trigger[trigger.to_upper()]] = json["effects"][trigger]

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

static func attack_type_from_string(str: String) -> AttackType:
	match str.to_lower():
		"hand":
			return AttackType.HAND
		"ballistic":
			return AttackType.BALLISTIC
		"spread":
			return AttackType.SPREAD
		"homing":
			return AttackType.HOMING
		"none":
			return AttackType.NONE
	return AttackType.ANY

static func get_type_name(type: int) -> String:
	match type:
		Type.BATTLE:
			return "Battle"
		Type.EVENT:
			return "Event"
		Type.SITUATION:
			return "Situation"
	return "N/A"

static func get_target_name(target: int) -> String:
	match target:
		AttackType.HAND:
			return "Hand"
		AttackType.BALLISTIC:
			return "Ballistic"
		AttackType.SPREAD:
			return "Spread"
		AttackType.HOMING:
			return "Homing"
		AttackType.NONE:
			return ""
	return "N/A"

static func get_attribute_icon(attr: int):
	if attr in attribute_icons:
		return attribute_icons[attr]
	return null

static func get_type_background(type: int):
	if type in type_backgrounds:
		return type_backgrounds[int]
	return null

static func get_rarity_icon(rare: int):
	if rare in rarity_icons:
		return rarity_icons[rare]
	return null
