extends Tutorial

class_name Tutorial9CharacterCards

func get_name() -> String:
	return "9: Character Cards"

func get_id() -> String:
	return "b9"

func get_description() -> String:
	return "TUTORIAL_9_DESCRIPTION"

func get_image() -> Resource:
	return load("res://tutorial/images/character_cards.png")

func is_playable() -> bool:
	return true

func get_hint(turn_count: int, event: Event) -> TutorialHint:
	match turn_count:
		3:
			if event is EventPhaseSet:
				return TutorialHint.new(0, "Lv 1 Shion is on your field,\nso you cannot play the one\nin your hand. Play AG-02-M\nand click \"End Phase\".")
		4:
			if event is EventPhaseEventBlock and event.player.id == 0:
				return TutorialHint.new(0, "End your Block Phase.")
		5:
			if event is EventPhaseMove:
				return TutorialHint.new(0, "Click \"End Phase\" until\nat your Set Phase.")
			elif event is EventPhaseEventBlock and event.player.id == 0:
				return TutorialHint.new(0, "Click \"End Phase\" until\nat your Set Phase.")
			elif event is EventPhaseSet:
				return TutorialHint.new(0, "Now you can play neither\nLv 1 Shion or AG-02-M\nas both are already on\nyour field. However, you can\nLevel Up your Lv 1 Shion\nto a Lv 10 Shion.")
			elif event is EventPhaseBattle:
				return TutorialHint.new(1, "Notice that your Lv 10 Shion is not at full HP. This is because the 2 damage taken by Lv 1 Shion was carried over.")
		6:
			if event is EventPhaseEventBlock and event.player.id == 0:
				return TutorialHint.new(0, "End your block phase.")
		7:
			if event is EventPhaseMove:
				return TutorialHint.new(0, "Click \"End Phase\" until at your Set Phase.")
			elif event is EventPhaseEventBlock and event.player.id == 0:
				return TutorialHint.new(0, "Click \"End Phase\" until at your Set Phase.")
			elif event is EventPhaseSet:
				return TutorialHint.new(0, "Now the Lv 10 Shion on your\nfield prevents you from playing\nboth Lv1 Shion and Swim Suit Shion.\nClick \"End Phase\".")
			elif event is EventPhaseEventBlock and event.player.id == 1:
				var hint: TutorialHint = TutorialHint.new(0, "")
				hint.exec = complete_tutorial
				return hint
	return null
