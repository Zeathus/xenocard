class_name ServerRoom

var id: int
var name: String
var host_name: String
var p1: ServerPeer
var p2: ServerPeer
var allowed_cards: String = ""
var password: String = ""

func _init() -> void:
	pass

func get_players() -> Array[ServerPeer]:
	return [p1, p2]

func to_str() -> String:
	return "\t".join([str(id), name, host_name, allowed_cards, "Yes" if len(password) > 0 else "No"])
