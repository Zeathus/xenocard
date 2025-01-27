extends Tutorial

class_name Tutorial11Gnosis

func get_name() -> String:
	return "11: Gnosis"

func get_id() -> String:
	return "b11"

func get_description() -> String:
	return "TUTORIAL_11_DESCRIPTION"

func get_image() -> Resource:
	return load("res://tutorial/images/gnosis.png")

func is_playable() -> bool:
	return true

func get_hint(turn_count: int, event: Event) -> TutorialHint:
	match turn_count:
		3:
			if event is EventPhaseSet:
				return TutorialHint.new(0, "Try playing the gnosis\ncards in your hand.")
			elif event is EventPhaseEventBlock:
				var hint: TutorialHint = TutorialHint.new(0, "")
				hint.exec = complete_tutorial
				return hint
	return null
