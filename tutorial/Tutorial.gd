class_name Tutorial

var completed: bool = false

func get_name() -> String:
	return "n/a"

func get_id() -> String:
	return "n/a"

func get_description() -> String:
	return "n/a"

func get_image() -> Resource:
	return null

func get_hint(turn_count: int, event: Event) -> TutorialHint:
	return null

func is_playable() -> bool:
	return false

func set_game_options(game: GameBoard) -> void:
	game.player_options.push_back({"ai": false})
	game.player_options.push_back({"ai": true})
	game.game_options["reveal_hands"] = false
	game.game_options["load_game"] = "res://tutorial/saved_games/" + get_id() + ".json"
	game.game_options["tutorial"] = self

func complete_tutorial(game_board: GameBoard):
	game_board.end_game(Enum.GameResult.TUTORIAL)

func is_completed() -> bool:
	return completed

func set_completed(val: bool) -> void:
	completed = val
	var tutorial_data: Dictionary = get_tutorial_data()
	tutorial_data[get_id()] = val
	var file_name = "user://tutorials.json"
	var file = FileAccess.open(file_name, FileAccess.WRITE)
	var json_string = JSON.stringify(tutorial_data)
	file.store_line(json_string)
	file.close()

static func get_tutorial_data() -> Dictionary:
	var file_name = "user://tutorials.json"
	if FileAccess.file_exists(file_name):
		# Load saved tutorials
		var file = FileAccess.open(file_name, FileAccess.READ)
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		file.close()
		if error == OK:
			return json.data
		else:
			Logger.e("Failed to to parse tutorial tutorial save file '%s'" % file_name)
			return {}
	else:
		# Create tutorial save file
		var file = FileAccess.open(file_name, FileAccess.WRITE)
		var json_data: Dictionary = {}
		var json_string = JSON.stringify(json_data)
		file.store_line(json_string)
		file.close()
		return json_data
