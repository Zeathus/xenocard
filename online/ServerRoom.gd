class_name ServerRoom

static var next_id: int = 0
var id: int
var name: String
var p1_name: String = ""
var p2_name: String = ""
var p1: ServerPeer = null
var p2: ServerPeer = null
var p1_deck: PackedStringArray
var p2_deck: PackedStringArray
var ruleset: Rulesets.Ruleset = 0
var password: String = ""
var countdown: float = 5.0
var actions: Array[Array] = [[], []]
var game_board: GameBoard = null

func _init() -> void:
	pass

func get_players() -> Array[ServerPeer]:
	return [p1, p2]

func remove_player(peer: ServerPeer):
	if p1 == peer:
		p1 = p2
		p1_name = p2_name
		p1_deck = p2_deck
		p2 = null
		p2_name = ""
		p2_deck = []
	elif p2 == peer:
		p2 = null
		p2_name = ""
		p2_deck = []

func update(delta: float):
	if p1 and p2 and len(p1_deck) > 0 and len(p2_deck) > 0:
		if countdown >= 0:
			countdown -= delta
	else:
		countdown = 5.0

func close():
	game_board.queue_free()

func on_game_end():
	if p1 != null:
		p1.state = TCGServer.ClientState.IN_ROOM
	if p2 != null:
		p2.state = TCGServer.ClientState.IN_ROOM

func to_str() -> String:
	return "\t".join([
		str(id), 
		name,
		p1_name,
		p2_name,
		str(ruleset),
		"1" if len(password) > 0 else "0",
		"1" if len(p1_deck) > 0 else "0",
		"1" if len(p2_deck) > 0 else "0"
	])

static func from_str(str: String) -> ServerRoom:
	var room: ServerRoom = ServerRoom.new()
	var args: PackedStringArray = str.split("\t")
	room.id = int(args[0])
	room.name = args[1]
	room.p1_name = args[2]
	room.p2_name = args[3]
	room.ruleset = int(args[4])
	room.password = args[5]
	room.p1_deck = ["Y"] if args[6] == "1" else []
	room.p2_deck = ["Y"] if args[7] == "1" else []
	return room

static func get_next_id() -> int:
	next_id = (next_id + 5431) % 1000000
	return next_id

static func verify_args(args: PackedStringArray) -> bool:
	return true
