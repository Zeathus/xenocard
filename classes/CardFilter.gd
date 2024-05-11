class_name CardFilter

var names: Array[String] = []
var characters: Array[String] = []
var attributes: Array[int] = []
var zones: Array[int] = []
var types: Array[int] = []
var owner: int = -1

func _init(str: String):
	for param in str.split(";"):
		var filter = param.split("=")
		var field = filter[0]
		var value = filter[1]
		match field:
			"name":
				names.push_back(value)
			"character":
				characters.push_back(value)
			"attribute":
				var attribute = Attribute_from_string(value.replace("!", ""))
				if value.begins_with("!"):
					for i in Attribute.values():
						if i != attribute:
							attributes.push_back(i)
				else:
					attributes.push_back(attribute)
			"zone":
				match value.to_lower():
					"battlefield":
						zones.push_back(Zone.BATTLEFIELD)
					"standby":
						zones.push_back(Zone.STANDBY)
					"situation":
						zones.push_back(Zone.SITUATION)
					"hand":
						zones.push_back(Zone.HAND)
					_:
						print("Invalid zone filter '%s'" % value)
			"type":
				types.push_back(Type_from_string(value))
			"owner":
				match value.to_lower():
					"self":
						owner = 0
					"enemy":
						owner = 1
					"any":
						owner = -1
					_:
						print("Invalid owner filter '%s'" % value)

func check_multiple(value, filter):
	if len(filter) == 0:
		return true
	for i in filter:
		if value ==  i:
			return true
	return false

func is_valid(player: Player, card: Card):
	if not check_multiple(card.name.replace("\n", " "), names):
		return false
	if not check_multiple(card.character, characters):
		return false
	if not check_multiple(Attribute, attributes):
		return false
	if not check_multiple(Zone, zones):
		return false
	if not check_multiple(Type, types):
		return false
	if owner == 0 and card.owner != player:
		return false
	if owner == 1 and card.owner == player:
		return false
	return true

func owner_only() -> bool:
	return owner == 0

func enemy_only() -> bool:
	return owner == 1
