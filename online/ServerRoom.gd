class_name ServerRoom

static var next_id: int = 0
var id: int
var name: String
var p1_name: String = ""
var p2_name: String = ""
var p1: ServerPeer = null
var p2: ServerPeer = null
var allowed_cards: int = 0
var password: String = ""

func _init() -> void:
	pass

func get_players() -> Array[ServerPeer]:
	return [p1, p2]

func remove_player(peer: ServerPeer):
	if p1 == peer:
		p1 = p2
		p1_name = p2_name
		p2 = null
		p2_name = ""
	elif p2 == peer:
		p2 = null
		p2_name = ""

func to_str() -> String:
	return "\t".join([str(id), name, p1_name, p2_name, str(allowed_cards), "1" if len(password) > 0 else "0"])

static func from_str(str: String) -> ServerRoom:
	var room: ServerRoom = ServerRoom.new()
	var args: PackedStringArray = str.split("\t")
	room.id = int(args[0])
	room.name = args[1]
	room.p1_name = args[2]
	room.p2_name = args[3]
	room.allowed_cards = int(args[4])
	room.password = args[5]
	return room

static func get_next_id() -> int:
	next_id = (next_id + 5431) % 1000000
	return next_id

static func verify_args(args: PackedStringArray) -> bool:
	return true
