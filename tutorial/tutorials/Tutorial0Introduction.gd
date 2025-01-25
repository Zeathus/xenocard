extends Tutorial

class_name Tutorial0Introduction

var explained_attack_order: bool = false
var explained_hand: bool = false
var explained_ballistic: bool = false

func get_name() -> String:
	return "0: Introduction"

func get_id() -> String:
	return "b0"

func get_description() -> String:
	return "TUTORIAL_0_DESCRIPTION"

func get_hint(turn_count: int, event: Event) -> TutorialHint:
	match turn_count:
		0:
			if event is EventStartTurn:
				return TutorialHint.new(1, "At the start of a game, each player draws 5 cards from their deck.")
		1:
			if event is EventMulligan:
				return TutorialHint.new(1, "At the start of your first turn, you can Mulligan up to 3 times.\nMulligan: Shuffle your hand into your deck and draw 5 new cards.\nDuring tutorials, it does nothing.")
			elif event is EventPhaseEventBlock and event.player.id == 0:
				return TutorialHint.new(0, "This is your Event Phase.\nYou can generally not play any\nEvent cards for your first event phase.\nClick the End Phase button on the\nleft to go to the next phase.")
			elif event is EventPhaseSet:
				return TutorialHint.new(0, "This is your Set Phase.\nHere you play Battle cards to the Standby Area\nand Situation cards to the Situation Area. Right now,\nyou can only play one Civilian Female. You can only\nplay one battle card and one situation card each turn.")
			elif event is EventPhaseEventBlock and event.player.id == 1:
				return TutorialHint.new(1, "When you play a battle card, it gets an E-mark until your Battle Phase. Cards with an E-mark do not count for field requirements (more on that next turn).")
			elif event is EventPhaseAdjust:
				return TutorialHint.new(1, "This is your Battle Phase.\nNo cards are on the battlefield, so nothing happens. The battle card you set earlier lost its E-mark.")
			elif event is EventStartTurn:
				return TutorialHint.new(1, "This is your Adjust Phase.\nSome card effects can happen during this phase. You also have to discard cards in your hand during this phase if you have more than 6 cards.")
			elif event is EventPhaseDraw:
				return TutorialHint.new(1, "After your Adjust Phase, it is your opponent's turn.")
		2:
			if event is EventPhaseEventBlock:
				return TutorialHint.new(0, "This is your Block Phase.\nHere you can play Event cards\nbefore your enemy's battle phase.\nYou have no cards to play now.")
			elif event is EventDrawCard:
				if event.game_board.turn_phase == Enum.Phase.ADJUST:
					return TutorialHint.new(1, "The enemy's Realian card activated its effect. You can right click cards to look at them more closely, then you can hover over words or stats for explanations.")
			elif event is EventPhaseDraw:
				return TutorialHint.new(1, "At the start of your turn, you draw one card from your deck.")
		3:
			if event is EventPhaseMove:
				return TutorialHint.new(0, "This is your Move Phase.\nIt is skipped when there are no cards to move.\nNow is your chance to move your battle cards\nfrom Standby to the Battlefield, where they can attack.")
			elif event is EventPhaseEventBlock:
				return TutorialHint.new(0, "There are still no Event cards to play.")
			elif event is EventPhaseSet:
				return TutorialHint.new(0, "Some cards have field requirements next to \"Field\" on the card.\nTo play the card, you need to have the attributes\nlisted on your field. White squares can be any attribute.\nA card's attribute is the icon on the top right of the card.\nWith two Civilian Female, you meet the requirements\nfor Stim and Rocket on your next turn.")
		4:
			if event is EventPhaseEventBlock:
				return TutorialHint.new(0, "There are still no Event cards to play.")
		5:
			if event is EventPhaseEventBlock:
				return TutorialHint.new(0, "If your battle card has taken damage,\nyou can now play Curry to heal it.")
			elif event is EventPhaseSet:
				return TutorialHint.new(0, "Now you meet the field requirements for Stim and Rocket.\nStim and other Situation cards give you various effects.\nRocket is a weapon card. It is equipped to battle cards on the field.\nRocket has the Unlimited effect, so you can play it\nthe same turn as another battle card.")

	if event is EventAttack and not explained_hand and event.attacker.get_attack_type() == Enum.AttackType.HAND:
		explained_hand = true
		return TutorialHint.new(1, "The attacking card has the Hand attack type. It can only attack cards in the front row while it is also in the front row.")
	elif event is EventAttack and not explained_ballistic and event.attacker.get_attack_type() == Enum.AttackType.BALLISTIC:
		explained_ballistic = true
		return TutorialHint.new(1, "The attacking card has the Ballistic attack type. It hits the first card in a line in front of it. If there are no cards to hit, it will hits the deck, moving cards to the lost pile equal to its ATK.")
	elif event is EventAttack and event.game_board.players[event.game_board.get_turn_player()].field.battlefield_count() > 1 and not explained_attack_order:
		return TutorialHint.new(1, "The cards on the battlefield attack in a specific order based on attack type:\n1. Hand, 2. Spread, 3. Ballistic, 4. Homing.\nCards with the same attack type follow the numbers on the battlefield.")
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
				"XS1/miyukis_email"
			]
		}
	})
	game.player_options.push_back({
		"ai": true,
		"deck": {
			"name": "Deck",
			"cards": [
				"XS1/realian_male",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion",
				"XS1/lv_1_shion"
			]
		}
	})
	game.game_options["reveal_hands"] = false
	game.game_options["unshuffled"] = true
	game.game_options["tutorial"] = self
