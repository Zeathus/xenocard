class_name CardData

static var data: Dictionary
static var path: String = "res://data/cards"

var game: String
var set_name: String
var set_id: int = -1
var id: String
var identifier: String
var name: String
var character: String
var type: Enum.Type
var rarity: Enum.Rarity
var attribute: Enum.Attribute
var max_hp: int
var atk: int
var attack_type: Enum.AttackType
var cost: int
var field: Array[Enum.Attribute]
var text: String
var effect_names: Array[String]
var event_effect_names: Array[String]
var effects: Array[EffectData]

func _init(_id: String):
	var json = get_json(_id)
	if not json.is_empty():
		load_json(json)

static func load_cards():
	data = {}
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
			var card_id = "%s/%s" % [set_name, card_file]
			var card = CardData.new(card_id)
			data[card_id] = card
			card_file = sub_dir.get_next()
		set_name = dir.get_next()
		sub_dir.list_dir_end()
	dir.list_dir_end()

static func get_data(_id: String) -> CardData:
	if _id in data:
		return data[_id]
	var new_data = CardData.new(_id)
	data[_id] = new_data
	return new_data

static func get_count() -> int:
	return len(data)

func get_json(_id: String) -> Dictionary:
	var card_set: String = _id.substr(0, _id.find("/"))
	id = _id.substr(len(card_set) + 1)
	var file_name: String = "%s/%s/%s.json" % [path, card_set, id]
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
	type = Enum.type_from_string(json["type"])
	match json["rarity"]:
		"common":
			rarity = Enum.Rarity.COMMON
		"uncommon":
			rarity = Enum.Rarity.UNCOMMON
		"rare":
			rarity = Enum.Rarity.RARE
		"promo":
			rarity = Enum.Rarity.PROMO
	cost = 0
	field = []
	if "requirement" in json:
		if "cost" in json["requirement"]:
			cost = json["requirement"]["cost"]
		if "field" in json["requirement"]:
			for i in json["requirement"]["field"]:
				field.push_back(Enum.attribute_from_string(i))
	if "text" in json:
		text = json["text"]
	else:
		text = ""

	if type == Enum.Type.BATTLE:
		max_hp = json["stats"]["hp"]
		atk = json["stats"]["atk"]
		attribute = Enum.attribute_from_string(json["stats"]["attribute"])
		attack_type = Enum.attack_type_from_string(json["stats"]["target"])

	#effect_names = []
	#if "effects" in json:
		#for i in json["effects"]:
			#effect_names.push_back(i)
#
	#event_effect_names = []
	#if "event_effects" in json:
		#for i in json["event_effects"]:
			#event_effect_names.push_back(i)

	if "effects" in json:
		for effect_dict in json["effects"]:
			if effect_dict is String:
				continue
			if "trigger" not in effect_dict:
				print("Trigger missing for effect for card '%s'" % name)
				continue
			if effect_dict["trigger"].to_upper() not in Enum.Trigger:
				print("Invalid effect Trigger '%s' for card '%s'" % [effect_dict["trigger"].to_upper(), name])
				continue
			var effect_data = EffectData.new(Enum.Trigger[effect_dict["trigger"].to_upper()])
			if "effect" not in effect_dict:
				print("Effect missing for effect for card '%s'" % name)
				continue
			for e in effect_dict["effect"]:
				if true: # validity check
					effect_data.effects.push_back(e)
			if "requirement" in effect_dict:
				for r in effect_dict["requirement"]:
					if true: # validity check
						effect_data.requirements.push_back(r)
			if "ignores_down" in effect_dict:
				effect_data.ignores_down = effect_dict["ignores_down"]
			if "global" in effect_dict:
				effect_data.global = effect_dict["global"]
			if "stackable" in effect_dict:
				effect_data.stackable = effect_dict["stackable"]
			
			effects.push_back(effect_data)

func get_image() -> Resource:
	var image_file: String = "res://sprites/card_images/%s/%s.png" % [set_name, id]
	if ResourceLoader.exists(image_file):
		return load(image_file)
	else:
		push_error("Failed to find card image '%s'" % image_file)
		return load("res://sprites/card_images/missing_artwork.png")

func get_baked_image() -> Resource:
	var image_file: String = "res://sprites/card_images_baked/%s/%s.png" % [set_name, id]
	if FileAccess.file_exists(image_file):
		return load(image_file)
	else:
		push_error("Failed to find card image '%s'" % image_file)
		return load("res://sprites/card_images/missing_artwork.png")

func has_baked_image() -> bool:
	var image_file: String = "res://sprites/card_images_baked/%s/%s.png" % [set_name, id]
	return FileAccess.file_exists(image_file)

func get_full_id() -> String:
	return "%s/%s" % [set_name, id]
