class_name Options

static var file_name = "user://options.json"
static var music_volume: int = 100
static var music_mute: bool = false
static var sounds_volume: int = 100
static var sounds_mute: bool = false
static var rotate_enemy_cards: bool = false
static var always_show_atk_boosts: bool = false
static var disable_block_reminder: bool = false
static var locale: String = "en"
static var username: String = ""

static func set_locale(_locale: String) -> void:
	locale = _locale
	TranslationServer.set_locale(locale)

static func set_music_volume(volume: int):
	music_volume = volume
	var db: float = (volume - 100) / 10.0
	var bus_index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(bus_index, db)
	AudioServer.set_bus_mute(bus_index, music_mute or volume == 0)

static func set_sounds_volume(volume: int):
	sounds_volume = volume
	var db: float = (volume - 100) / 10.0
	var bus_index = AudioServer.get_bus_index("Sounds")
	AudioServer.set_bus_volume_db(bus_index, db)
	AudioServer.set_bus_mute(bus_index, sounds_mute or volume == 0)

static func set_music_mute(value: bool):
	music_mute = value
	var bus_index = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_mute(bus_index, value)

static func set_sounds_mute(value: bool):
	sounds_mute = value
	var bus_index = AudioServer.get_bus_index("Sounds")
	AudioServer.set_bus_mute(bus_index, value)

static func to_dict() -> Dictionary:
	return {
		"music": music_volume,
		"music_mute": music_mute,
		"sounds": sounds_volume,
		"sounds_mute": sounds_mute,
		"rotate_enemy_cards": rotate_enemy_cards,
		"always_show_atk_boosts": always_show_atk_boosts,
		"disable_block_reminder": disable_block_reminder,
		"locale": locale,
		"username": username,
	}

static func load() -> void:
	if FileAccess.file_exists(file_name):
		var file = FileAccess.open(file_name, FileAccess.READ)
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		file.close()
		if error == OK:
			var data: Dictionary = json.data
			set_music_volume(data["music"])
			set_music_mute(data["music_mute"])
			set_sounds_volume(data["sounds"])
			set_sounds_mute(data["sounds_mute"])
			rotate_enemy_cards = data["rotate_enemy_cards"]
			always_show_atk_boosts = data["always_show_atk_boosts"]
			disable_block_reminder = data["disable_block_reminder"] if "disable_block_reminder" in data else false
			set_locale(data["locale"])
			username = data["username"] if "username" in data else ""
		else:
			Logger.e("Error loading options.json")
			save()
	else:
		save()

static func save() -> void:
	var file = FileAccess.open(file_name, FileAccess.WRITE)
	var json_string = JSON.stringify(to_dict())
	file.store_line(json_string)
	file.close()
