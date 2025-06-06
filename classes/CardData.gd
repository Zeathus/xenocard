class_name CardData

static var data: Dictionary
static var path: String = "res://data/cards"
static var image_root: String = "res://sprites/"
static var image_type: String = "png"

var game: String
var set_name: String
var set_id: int = -1
var set_number: int = 0
var id: String
var identifier: String
var name: Dictionary
var character: String
var type: Enum.Type
var rarity: Enum.Rarity
var attribute: Enum.Attribute
var max_hp: int
var atk: int
var attack_type: Enum.AttackType
var cost: int
var field: Array[Enum.Attribute]
var text: Dictionary
var effect_names: Array[String]
var event_effect_names: Array[String]
var effects: Array[EffectData]
var full_art: int = 0
var artist: String
# name and text, but with formatting removed (for searching)
var raw_name: Dictionary
var raw_text: Dictionary

static func _static_init() -> void:
	if OS.get_name() == "HTML5" or OS.get_name() == "Web":
		image_root = "res://sprites/web/"
		image_type = "webp"

func _init(_id: String):
	var json = get_json(_id)
	if not json.is_empty():
		load_json(json)

func get_name() -> String:
	if Options.locale not in name:
		if "en" in name:
			return name["en"]
		return "N/A"
	return name[Options.locale]

func get_text() -> String:
	if Options.locale not in text:
		if "en" in text:
			return text["en"]
		return "N/A"
	return text[Options.locale]

func get_raw_name() -> String:
	if Options.locale not in raw_name:
		if "en" in raw_name:
			return raw_name["en"]
		return "N/A"
	return raw_name[Options.locale]

func get_raw_text() -> String:
	if Options.locale not in raw_text:
		if "en" in raw_text:
			return raw_text["en"]
		return "N/A"
	return raw_text[Options.locale]

static func load_cards():
	data = {}
	var dir = DirAccess.open(path)
	if not dir:
		Logger.e("Failed to find card directory.")
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
			if ".json" not in card_file:
				card_file = sub_dir.get_next()
				continue
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

static func has_data(_id: String) -> bool:
	return _id in data

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
			Logger.e("Failed to to parse card file '%s'" % file_name)
	else:
		Logger.e("Failed to find card file '%s'" % file_name)
	return {}

func load_json(json: Dictionary):
	game = json["game"]
	set_name = json["set"]
	set_id = json["id"]
	set_number = json["set_number"]
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
		text = {"en": ""}
	
	if "full_art" in json:
		full_art = json["full_art"]
	
	if "artist" in json:
		artist = json["artist"]
	else:
		artist = "Monolith Soft"

	if type == Enum.Type.BATTLE:
		max_hp = json["stats"]["hp"]
		atk = json["stats"]["atk"]
		attribute = Enum.attribute_from_string(json["stats"]["attribute"])
		attack_type = Enum.attack_type_from_string(json["stats"]["target"])

	if "effects" in json:
		for effect_dict in json["effects"]:
			var effect_data = EffectData.parse(effect_dict, name)
			if effect_data == null:
				Logger.e("Failed to get effect data for " + get_name())
				continue
			effects.push_back(effect_data)
	
	raw_name = {}
	raw_text = {}
	for i in name:
		raw_name[i] = remove_formatting(name[i])
	for i in text:
		raw_text[i] = remove_formatting(text[i])

func get_image() -> Resource:
	if OS.has_feature("dedicated_server"):
		return null
	var image_file: String = "%s/card_images/%s/%s.%s" % [image_root, set_name, id, image_type]
	if ResourceLoader.exists(image_file):
		return load(image_file)
	else:
		Logger.e("Failed to find card image '%s'" % image_file)
		return load("%s/card_images/missing_artwork.%s" % [image_root, image_type])

func get_baked_image() -> Resource:
	if OS.has_feature("dedicated_server"):
		return null
	var image_file: String = "%s/card_images_baked/%s/%s/%s.%s" % [image_root, Options.locale, set_name, id, image_type]
	if ResourceLoader.exists(image_file):
		return load(image_file)
	else:
		Logger.e("Failed to find card image '%s'" % image_file)
		return load("%s/card_images_baked/en/SYS/unknown.%s" % [image_root, image_type])

func has_baked_image() -> bool:
	var image_file: String = "%s/card_images_baked/%s/%s/%s.%s" % [image_root, Options.locale, set_name, id, image_type]
	return FileAccess.file_exists(image_file)

func get_full_id() -> String:
	return "%s/%s" % [set_name, id]

static func remove_formatting(text: String) -> String:
	text = text.replace("\n", " ")
	for i in "{}<>[]$":
		text = text.replace(i, "")
	return text
