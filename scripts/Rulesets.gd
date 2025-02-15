class_name Rulesets

enum Ruleset {
	NONE = 0,
	STANDARD = 1,
	LEGACY = 2,
	ALLOW_BETA = 3,
}

enum Legality {
	OK = 0,
	NOT_40_CARDS = 1,
	NO_SUCH_CARD = 2,
	ILLEGAL_CARD = 3,
	TOO_MANY_DUPES = 4,
}

static func count():
	return 4

static func get_title(ruleset: Ruleset) -> String:
	match ruleset:
		Ruleset.NONE:
			return "Any"
		Ruleset.STANDARD:
			return "Standard"
		Ruleset.LEGACY:
			return "Legacy"
		Ruleset.ALLOW_BETA:
			return "Allow Beta Cards"
	return "N/A"

static func get_description(ruleset: Ruleset) -> String:
	match ruleset:
		Ruleset.NONE:
			return "Show rooms regardless of ruleset"
		Ruleset.STANDARD:
			return "Allow all cards, except beta cards"
		Ruleset.LEGACY:
			return "Allow only the original cards from Xenosaga 1"
		Ruleset.ALLOW_BETA:
			return "Allow all cards, including beta cards"
	return "N/A"

static func verify_deck(ruleset: Ruleset, card_ids: PackedStringArray) -> Legality:
	var counts: Dictionary = {}
	if len(card_ids) != 40:
		return Legality.NOT_40_CARDS # Not 40 cards
	var legal_sets = ["XS1"]
	for card_id in card_ids:
		if not CardData.has_data(card_id) or "/" not in card_id:
			return Legality.NO_SUCH_CARD # Has a non-existent card
		var set_and_name: PackedStringArray = card_id.split("/")
		if set_and_name[0] not in legal_sets:
			return Legality.ILLEGAL_CARD # Has illegal card for ruleset
		var real_name: String = CardData.get_data(card_id).raw_name
		if real_name not in counts:
			counts[real_name] = 1
		else:
			counts[real_name] += 1
			if counts[real_name] > 3:
				return Legality.TOO_MANY_DUPES # Has more than 3 copies of a card
	return 0
