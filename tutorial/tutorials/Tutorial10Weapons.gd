extends Tutorial

class_name Tutorial10Weapons

func get_name() -> String:
	return "10: Weapons"

func get_id() -> String:
	return "b10"

func get_description() -> String:
	return "TUTORIAL_10_DESCRIPTION"

func get_image() -> Resource:
	return load("res://tutorial/images/weapons.png")

func is_playable() -> bool:
	return true

func get_hint(turn_count: int, event: Event) -> TutorialHint:
	match turn_count:
		3:
			if event is EventPhaseSet:
				return TutorialHint.new(0, "You have many weapon cards in your hand.\nTry equipping them to applicable cards.\nMany weapon cards have the Unlimited effect,\nbut not all of them.")
			elif event is EventPhaseEventBlock:
				var hint: TutorialHint = TutorialHint.new(0, "")
				hint.exec = complete_tutorial
				return hint
	return null
