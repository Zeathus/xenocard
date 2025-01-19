class_name AppMeta

static var major_ver: int = 0
static var minor_ver: int = 1
static var build_ver: int = 0

static func get_version_string() -> String:
	return "%d.%d.%d" % [major_ver, minor_ver, build_ver]

static func get_version_id() -> int:
	return major_ver * 10000 + minor_ver * 100 + build_ver
