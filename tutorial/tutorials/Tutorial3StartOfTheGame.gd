extends Tutorial

class_name Tutorial3StartOfTheGame

var mulligan_tutorial: bool = false

func get_name() -> String:
	return "3: Start of the Game"

func get_id() -> String:
	return "b3"

func get_description() -> String:
	return "TUTORIAL_3_DESCRIPTION"

func is_playable() -> bool:
	return true

func get_hint(turn_count: int, event: Event) -> TutorialHint:
	match turn_count:
		0:
			if event is EventStartTurn:
				return TutorialHint.new(1, "At the start of a game, each player draws 5 cards from their deck.")
		1:
			if event is EventMulligan and not mulligan_tutorial:
				mulligan_tutorial = true
				return TutorialHint.new(1, "At the start of your first turn, you can Mulligan up to 3 times to try to get a better starting hand.\nMulligan: Shuffle your hand into your deck and draw 5 new cards.")
			elif event is EventPhaseMove:
				return TutorialHint.new(1, "After your chance to mulligan, your turn starts, and you draw card. You draw a card at the start of each turn.")
			elif event is EventPhaseEventBlock:
				var hint: TutorialHint = TutorialHint.new(1, "The player that goes second gets their chance to mulligan at the start of their first turn, after the player going first has had their first turn.")
				hint.exec = complete_tutorial
				return hint
	return null

func set_game_options(game: GameBoard) -> void:
	game.player_options.push_back({
		"ai": false,
		"deck": {
			"name": "Deck",
			"cards": [
				"XS1/civilian_female",
				"XS1/stim",
				"XS1/curry",
				"XS1/civilian_female",
				"XS1/kukai_foundation",
				"XS1/rocket",
				"XS1/cannon",
				"XS1/simeon",
				"XS1/lv_1_ziggy",
				"XS1/dammerung",
				"XS1/drone",
				"XS1/lv_1_ziggy",
				"XS1/supply_fleet",
				"XS1/lv_10_ziggy",
				"XS1/miyukis_email",
				"XS1/civilian_female",
				"XS1/stim",
				"XS1/curry",
				"XS1/civilian_female",
				"XS1/kukai_foundation",
				"XS1/rocket",
				"XS1/cannon",
				"XS1/simeon",
				"XS1/lv_1_ziggy",
				"XS1/dammerung",
				"XS1/drone",
				"XS1/lv_1_ziggy",
				"XS1/supply_fleet",
				"XS1/lv_10_ziggy",
				"XS1/miyukis_email",
				"XS1/civilian_female",
				"XS1/stim",
				"XS1/curry",
				"XS1/civilian_female",
				"XS1/kukai_foundation",
				"XS1/rocket",
				"XS1/cannon",
				"XS1/simeon",
				"XS1/lv_1_ziggy",
				"XS1/dammerung",
			]
		}
	})
	game.player_options.push_back({
		"ai": true,
		"deck": {
			"name": "Deck",
			"cards": [
				"XS1/civilian_female",
				"XS1/stim",
				"XS1/curry",
				"XS1/civilian_female",
				"XS1/kukai_foundation",
				"XS1/rocket",
				"XS1/cannon",
				"XS1/simeon",
				"XS1/lv_1_ziggy",
				"XS1/dammerung",
				"XS1/drone",
				"XS1/lv_1_ziggy",
				"XS1/supply_fleet",
				"XS1/lv_10_ziggy",
				"XS1/miyukis_email",
				"XS1/civilian_female",
				"XS1/stim",
				"XS1/curry",
				"XS1/civilian_female",
				"XS1/kukai_foundation",
				"XS1/rocket",
				"XS1/cannon",
				"XS1/simeon",
				"XS1/lv_1_ziggy",
				"XS1/dammerung",
				"XS1/drone",
				"XS1/lv_1_ziggy",
				"XS1/supply_fleet",
				"XS1/lv_10_ziggy",
				"XS1/miyukis_email",
				"XS1/civilian_female",
				"XS1/stim",
				"XS1/curry",
				"XS1/civilian_female",
				"XS1/kukai_foundation",
				"XS1/rocket",
				"XS1/cannon",
				"XS1/simeon",
				"XS1/lv_1_ziggy",
				"XS1/dammerung",
			]
		}
	})
	game.game_options["reveal_hands"] = false
	game.game_options["unshuffled"] = true
	game.game_options["tutorial"] = self
