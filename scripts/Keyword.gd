class_name Keyword

static var regex_hint
static var regex_icon
static var regex_terms

static func _static_init():
	regex_hint = RegEx.new()
	regex_hint.compile("\\<([^\\>]+)\\>")
	regex_icon = RegEx.new()
	regex_icon.compile("\\{([^\\}]+)\\}")
	regex_terms = RegEx.new()
	regex_terms.compile("(?i)[ ,.](%s)[ ,.]" % get_all_terms())

static func expand_keywords(str: String) -> String:
	var expanded: String = str
	while true:
		var result = regex_hint.search(expanded)
		if not result:
			break
		expanded = \
			expanded.substr(0, result.get_start()) + \
			Keyword.expand_keyword(result.get_string(1)) + \
			expanded.substr(result.get_end())
	while true:
		var result = regex_icon.search(expanded)
		if not result:
			break
		expanded = \
			expanded.substr(0, result.get_start()) + \
			Keyword.expand_icon(result.get_string(1)) + \
			expanded.substr(result.get_end())
	while true:
		var result = regex_terms.search(expanded)
		if not result:
			break
		expanded = \
			expanded.substr(0, result.get_start() + 1) + \
			Keyword.expand_term(result.get_string(1)) + \
			expanded.substr(result.get_end() - 1)
	expanded = expanded.replace("$", "")
	return expanded

static func expand_keyword(keyword: String) -> String:
	var expanded: String = "[url=%s][color=#ffff86]" % keyword.to_lower()
	match keyword.to_lower():
		_:
			expanded += keyword
	expanded += "[/color][/url]"
	return expanded

static func expand_icon(keyword: String) -> String:
	var image_name: String = keyword.to_lower()
	match keyword.to_lower():
		"weapons":
			image_name = "weapon"
		"realians":
			image_name = "realian"
		"humans":
			image_name = "human"
		"blades":
			image_name = "blade"
		"monsters":
			image_name = "monster"
		"machines":
			image_name = "machine"
	return "[img height=\"40\"]res://sprites/text_icons/%s.png[/img]%s" % [image_name, keyword]

static func expand_term(keyword: String) -> String:
	var expanded: String = "[url=%s][color=#c6c6ff]" % keyword.to_lower()
	match keyword.to_lower():
		_:
			expanded += keyword
	expanded += "[/color][/url]"
	return expanded

static func get_hint(keyword: String) -> String:
	match keyword.to_lower():
		### KEYWORDS ###
		"down", "downed":
			return "[u]Downed[/u]\nThe card cannot attack and its effects are neutralized. Removed during the owner's adjust phase."
		"search":
			return "[u]Search[/u]\nAdd the specified card(s) from your deck to your hand.\nShuffle your deck afterwards."
		"unlimited":
			return "[u]Unlimited[/u]\nThe one card per turn rule does not apply to this card."
		"unique":
			return "[u]Unique[/u]\nYou can only have one of these cards on your field at a time."
		"level up":
			return "[u]Level Up[/u]\nDiscard the specified card on your battlefield to play this card in its place without cost or an E mark. Any damage carries over."
		"recover", "recovers":
			return "[u]Recover[/u]\nMove cards from the top of the lost pile into the deck.\nShuffle your deck afterwards."
		"slow":
			return "[u]Slow[/u]\nThe card can only be used during your event phase, not your block phase."
		"evade":
			return "[u]Evade[/u]\nAttacks ignore the card. Ballistic attacks hit the card or deck behind it instead."
		"penetrate", "penetrates", "penetrating":
			return "[u]Penetrate[/u]\nIf the attack destroys its target, any damage exceeding the target's HP is inflicted to the next card or deck behind it."
		"deploy", "deployed":
			return "[u]Deploy[/u]\nWhen a card is deployed, it is moved from the standby area to the battlefield."
		### TERMS ###
		"field requirements":
			return "To set a card, the attributes listed as field requirements must be present on your field. Cards with an E mark do not count towards field requirements."
		"field":
			return "The field includes all three areas where cards are in play. These are the standby, battlefield and situation areas."
		"battlefield":
			return "The battlefield are the four zones in the center. It does not include the standby or situation areas. Cards in these zones attack during the battle phase."
		"standby area", "standby":
			return "Cards set from the hand are set to the standby area. Cards in standby do not attack."
		"situation area":
			return "The situation area is specifically for situation cards that are currently active."
		"cost":
			return "Cost is paid when setting cards or from effects. Move cards from the top of the deck to the lost pile equal to the cost."
		"hand":
			return "The hand attack type can only attack the front row of the enemy's battlefield from the front row of your battlefield."
		"ballistic":
			return "The ballistic attack type attacks the closest enemy in any of the enemy battlefield zones in front of it. If there are no enemies, it attacks the enemy's deck."
		"spread":
			return "The spread attack type deals damage to every enemy card on their battlefield at once, but cannot attack the enemy's deck."
		"homing":
			return "The homing attack type ignores any enemy cards on the battlefield and attacks the enemy's deck directly."
		"junk pile", "junk":
			return "Destroyed and discarded cards go to the junk pile."
		"lost pile", "lost":
			return "When cost is paid or a deck is hit by an attack, cards are sent to the lost pile."
		"removed from the game", "remove from the game":
			return "Cards removed from the game cannot be obtained again."
		"e mark":
			return "When cards are set, they get an E mark. Cards with an E mark do not count for field requirements and cannot activate their effects. E marks are removed before the battle phase."
		"character cards", "character card":
			return "For each character, you can only have one battle card with their name on your field at a time. For example, Lv 1 Shion and Lv 10 Shion are the same character."
		"cannot be stacked":
			return "If there is more than one of these cards on your field, the effect only applies once. If a different card has the same effect, the effect is applied twice."
	return "Unknown keyword"

static func get_all_terms() -> String:
	var terms: Array[String] = [
		"field requirements",
		"field",
		"battlefield",
		"standby area",
		"standby",
		"situation area",
		"cost",
		"hand",
		"ballistic",
		"spread",
		"homing",
		"junk pile",
		"junk",
		"lost pile",
		"lost",
		"removed from the game",
		"remove from the game",
		"e mark",
		"character cards", "character card",
		"cannot be stacked"
	]
	var ret: String = ""
	for i in terms:
		if len(ret) != 0:
			ret += "|"
		ret += i
	return ret
