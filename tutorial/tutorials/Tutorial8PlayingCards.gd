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
				return TutorialHint.new(0, "This is your event phase.\nYou do not have the field\nrequirements for Mary and Shelley.\nClick \"End Phase\".")
			elif event is EventPhaseSet:
				return TutorialHint.new(0, "This is your set phase.\nYou can now play one battle card\nand one situation card.\nYou cannot play Stim yet as you\ndo not have its field requirements.\nPlay a card by clicking it,\nthen a free standby zone.")
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
		6:
			if event is EventPhaseEventBlock and event.player.id == 0:
				return TutorialHint.new(0, "You now meet the requirements\nfor Mary and Shelley.\nYou can play it now, or\nduring your next event phase.")
			elif event is EventPhaseSet:
				return TutorialHint.new(0, "You drew a Combat Realian Male.\nIt has the \"Unlimited\" effect,\nso you can play it the same\nturn as other battle cards.")
			
	#hint.exec = complete_tutorial
	#return hint
	return null
