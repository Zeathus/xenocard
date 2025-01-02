class_name CardFilter

var string: String
var names: Array[String] = []
var characters: Array[String] = []
var attributes: Array[Enum.Attribute] = []
var zones: Array[Enum.Zone] = []
var zone_indices: Array[int] = []
var types: Array[Enum.Type] = []
var attack_types: Array[Enum.AttackType] = []
var owner: int = -1
var relation: int = -1
var formula: String = ""
var downed: String = ""
var unique: String = ""
var e_mark: String = ""
var weapon: String = ""

func _init(filter_str: String):
	string = filter_str
	for param in filter_str.split(";"):
		var filter = param.split("=")
		var field = filter[0]
		var value = filter[1] if len(filter) > 1 else ""
		match field:
			"name":
				names.push_back(value)
			"character":
				characters.push_back(value)
			"attribute":
				var attribute = Enum.attribute_from_string(value.replace("!", ""))
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
			"zoneindex":
				zone_indices.push_back(int(value)-1)
			"type":
				types.push_back(Enum.type_from_string(value))
			"attacktype":
				attack_types.push_back(Enum.attack_type_from_string(value))
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
			"self":
				relation = 0
			"target":
				relation = 1
			"attacker":
				relation = 2
			"downed":
				downed = value
			"unique":
				unique = value
			"emark":
				e_mark = value
			"weapon":
				weapon = value
			"formula":
				formula = value

func check_multiple(value, filter):
	if len(filter) == 0:
		return true
	for i in filter:
		if value ==  i:
			return true
	return false

func is_valid(player: Player, card: Card, variables: Dictionary = {}):
	if not check_multiple(card.get_name().replace("\n", " "), names):
		return false
	if not check_multiple(card.get_character(), characters):
		return false
	if not check_multiple(card.get_attribute(), attributes):
		return false
	if not check_multiple(card.zone, zones):
		return false
	if not check_multiple(card.zone_index, zone_indices):
		return false
	if not check_multiple(card.get_type(), types):
		return false
	if not check_multiple(card.get_attack_type(), attack_types):
		return false
	if owner == 0 and card.owner != player:
		return false
	if owner == 1 and card.owner == player:
		return false
	if relation == 0 and ("self" not in variables or card != variables["self"]):
		return false
	if relation == 1 and ("target" not in variables or card != variables["target"]):
		return false
	if relation == 2 and ("attacker" not in variables or card != variables["attacker"]):
		return false
	if downed != "" and downed != str(card.downed):
		return false
	if unique != "" and unique != ("true" if card.conflicts_with_card(card) else "false"):
		return false
	if e_mark != "" and e_mark != str(card.e_mark):
		return false
	if weapon != "" and weapon != str(card.equipped_weapon != null):
		return false
	if formula != "" and not Formula.calc(formula, card, card.owner.game_board):
		return false
	return true

func owner_only() -> bool:
	return owner == 0

func enemy_only() -> bool:
	return owner == 1
