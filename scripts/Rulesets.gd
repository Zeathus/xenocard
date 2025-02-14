class_name Rulesets

enum Ruleset {
	NONE = 0,
	STANDARD = 1,
	LEGACY = 2,
	ALLOW_BETA = 3,
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
