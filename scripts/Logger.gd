class_name Logger

static var id: String = ""

static func i(msg: String):
	print(format_msg(msg))

static func w(msg: String):
	print("W: ", format_msg(msg))
	push_warning(format_msg(msg))

static func e(msg: String):
	print("E: ", format_msg(msg))
	push_error(format_msg(msg))

static func format_msg(msg: String):
	if id == "":
		return "[%s] %s" % [
			Time.get_datetime_string_from_system(),
			msg
		]
	else:
		return "<%s> [%s] %s" % [
			id,
			Time.get_datetime_string_from_system(),
			msg
		]
