class_name CardFilter

var names: Array[String] = []
var characters: Array[String] = []
var attributes: Array[Enum.Attribute] = []
var zones: Array[Enum.Zone] = []
var types: Array[Enum.Type] = []
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
				var attribute = Card.attribute_from_string(value.replace("!", ""))
				if value.begins_with("!"):
					for i in Enum.Attribute.values():
						if i != attribute:
							attributes.push_back(i)
				else:
					attributes.push_back(attribute)
			"zone":
				match value.to_lower():
					"battlefield":
						zones.push_back(Enum.Zone.BATTLEFIELD)
					"standby":
						zones.push_back(Enum.Zone.STANDBY)
					"situation":
						zones.push_back(Enum.Zone.SITUATION)
					"hand":
						zones.push_back(Enum.Zone.HAND)
					_:
						print("Invalid zone filter '%s'" % value)
			"type":
				types.push_back(Card.type_from_string(value))
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
	if not check_multiple(card.attribute, attributes):
		return false
	if not check_multiple(card.zone, zones):
		return false
	if not check_multiple(card.type, types):
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
