extends Tutorial

class_name Tutorial8PlayingCards

func get_name() -> String:
	return "8: Playing Cards"

func get_id() -> String:
	return "b8"

func get_description() -> String:
	return "TUTORIAL_8_DESCRIPTION"

func get_image() -> Resource:
	return load("res://tutorial/images/playing_cards.png")

func is_playable() -> bool:
	return true

func get_hint(turn_count: int, event: Event) -> TutorialHint:
	match turn_count:
		3:
			if event is EventPhaseEventBlock and event.player.id == 0:
				return TutorialHint.new(0, "This is your event phase.\nYou do not have the field\nrequirements for Mary & Shelley.\nClick \"End Phase\".")
			elif event is EventPhaseSet:
				return TutorialHint.new(0, "This is your set phase.\nYou can now play one battle card\nand one situation card.\nYou cannot play Stim yet as you\ndo not have its field requirements.\nPlay a card by clicking it,\nthen a free standby zone.")
			elif event is EventPhaseBattle:
				return TutorialHint.new(1, "You battle phase starts now. The card you played will lose its E-mark and start counting for field requirements.")
		4:
			if event is EventPhaseEventBlock and event.player.id == 0:
				return TutorialHint.new(0, "This is your block phase.\nYou still cannot play any event cards.\nClick \"End Phase\".")
		5:
			if event is EventPhaseMove:
				return TutorialHint.new(0, "This is your move phase.\nYou can move cards to or from\nthe battlefield.\nWhen done, click \"End Phase\".")
			elif event is EventPhaseEventBlock and event.player.id == 0:
				return TutorialHint.new(0, "Click \"End Phase\" to\ngo to your Set Phase.")
			elif event is EventPhaseSet:
				return TutorialHint.new(0, "You drew a Combat Realian Male.\nIt has the \"Unlimited\" effect,\nso you can play it the same\nturn as other battle cards.")
			elif event is EventPhaseBattle:
				return TutorialHint.new(1, "Your cards now lose their E-marks. You now meet the field requirements to play Mary & Shelley at your next event or block phase.")
		6:
			if event is EventPhaseEventBlock and event.player.id == 0:
				return TutorialHint.new(0, "You now meet the requirements\nfor Mary & Shelley.\nPlay it now to draw more cards.")
		7:
			if event is EventPhaseMove:
				return TutorialHint.new(0, "Move the cards you want\nthen click \"End Phase\".")
			elif event is EventPhaseEventBlock and event.player.id == 0:
				return TutorialHint.new(0, "You cannot play Supply Fleet\nas there are no cards\nto recover from lost.")
			elif event is EventPhaseSet:
				return TutorialHint.new(0, "You meet the requirement for both\nStim and Drone, but not Durandal.\nPlay both Stim and Drone.")
		8:
			if event is EventPhaseEventBlock and event.player.id == 0:
				return TutorialHint.new(0, "You paid 2 cost to play Drone.\nYou can play Supply Fleet now\nto recover those cards, or\nwait until you play Durandal\nto recover more cards.")
		9:
			if event is EventPhaseMove:
				return TutorialHint.new(0, "Remember to make sure you have\nfree spots in standby so you\ncan play more battle cards.")
			elif event is EventPhaseEventBlock and event.player.id == 0:
				return TutorialHint.new(0, "Click \"End Phase\" to\ngo to your Set Phase.")
			elif event is EventPhaseSet:
				return TutorialHint.new(0, "You meet the requirement for both\nDurandal and Kukai Foundation.\nPlay both of them.")
		10:
			if event is EventPhaseEventBlock and event.player.id == 0:
				return TutorialHint.new(0, "You can play Supply Fleet now\nif you saved it from earlier.")
			elif event is EventPhaseBattle:
				var hint: TutorialHint = TutorialHint.new(0, "You can play Supply Fleet now\nif you saved it from earlier.")
				hint.exec = complete_tutorial
				return hint
	return null
