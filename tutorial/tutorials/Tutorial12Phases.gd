extends Tutorial

class_name Tutorial12Phases

func get_name() -> String:
	return "12: Phases"

func get_id() -> String:
	return "b12"

func get_description() -> String:
	return "TUTORIAL_12_DESCRIPTION"

func is_playable() -> bool:
	return true

func get_hint(turn_count: int, event: Event) -> TutorialHint:
	match turn_count:
		3:
			if event is EventPhaseDraw and event.player.id == 0:
				return TutorialHint.new(1, "At the start of your turn is the Draw Phase. You draw a card.")
			elif event is EventPhaseMove:
				return TutorialHint.new(0, "This is your Move Phase.\nMove any cards you want between\nyour standby area and battlefield.")
			elif event is EventPhaseEventBlock and event.player.id == 0:
				return TutorialHint.new(0, "This is your Event Phase.\nYou can now play your event cards.")
			elif event is EventPhaseSet and event.player.id == 0:
				return TutorialHint.new(0, "This is your Set Phase.\nYou can now play battle and\nsituation cards.")
			elif event is EventPhaseEventBlock and event.player.id == 1:
				return TutorialHint.new(1, "Now starts your enemy's Block Phase. They can use event cards to disrupt you.")
			elif event is EventPhaseBattle:
				return TutorialHint.new(1, "Now starts your Battle Phase. Your cards will attack if able.")
			elif event is EventPhaseDraw and event.player.id == 1:
				return TutorialHint.new(1, "Your opponent now draws a card for their Draw Phase.")
		4:
			if event is EventPhaseDraw and event.player.id == 1:
				return TutorialHint.new(1, "Your opponent now draws a card for their Draw Phase.")
			elif event is EventPhaseEventBlock and event.player.id == 0:
				return TutorialHint.new(0, "Now it is your Block Phase.\nYou can play event cards to\ndisrupt the enemy.")
			elif event is EventPhaseBattle:
				return TutorialHint.new(1, "Now starts the enemy Battle Phase. The enemy cards will attack if able.")
			elif event is EventPhaseAdjust:
				return TutorialHint.new(1, "Now is the enemy Adjust Phase.\nCard effects will activate.")
		5:
			if event is EventPhaseMove and event.player.id == 0:
				var hint: TutorialHint = TutorialHint.new(1, "That ends a full round with turns from both players.")
				hint.exec = complete_tutorial
				return hint
	return null
