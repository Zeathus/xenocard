extends Node2D

signal join(room: ServerRoom)

var room: ServerRoom

func set_room(_room: ServerRoom) -> void:
	room = _room
	$Panel/RoomName.text = room.name
	$Panel/HostName.text = room.p1_name
	$Panel/Ruleset.text = Rulesets.get_title(room.ruleset)
	$Panel/HasPassword.text = "Yes" if room.password == "1" else "No"

func _on_join_button_pressed() -> void:
	join.emit(room)
