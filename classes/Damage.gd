class_name Damage

static var BATTLE: int        = 1
static var NORMAL_ATTACK: int = 1 << 1
static var EFFECT: int        = 1 << 2
static var DISCARD: int       = 1 << 3
static var DESTROY: int       = 1 << 4
static var PENETRATING: int   = 1 << 5

var flags: int = 0

func _init(_flags = 0):
	flags = _flags

func battle() -> bool:
	return (flags & BATTLE) != 0

func normal_attack() -> bool:
	return (flags & NORMAL_ATTACK) != 0

func effect() -> bool:
	return (flags & EFFECT) != 0

func discard() -> bool:
	return (flags & DISCARD) != 0

func destroy() -> bool:
	return (flags & DESTROY) != 0

func penetrating() -> bool:
	return (flags & PENETRATING) != 0

func get_online_id() -> String:
	return str(flags)

static func from_online_id(online_id: String) -> Damage:
	return Damage.new(int(online_id))
