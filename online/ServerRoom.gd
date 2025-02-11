class_name ServerRoom

static var next_id: int = 0
var id: int
var name: String
var host_name: String
var p1: ServerPeer
var p2: ServerPeer
var allowed_cards: int = 0
var password: String = ""

func _init() -> void:
	pass

func get_players() -> Array[ServerPeer]:
	return [p1, p2]

func to_str() -> String:
	return "\t".join([str(id), name, host_name, str(allowed_cards), "1" if len(password) > 0 else "0"])

static func get_next_id() -> int:
	next_id = (next_id + 5431) % 1000000
	return next_id

static func verify_args(args: PackedStringArray) -> bool:
	return true
