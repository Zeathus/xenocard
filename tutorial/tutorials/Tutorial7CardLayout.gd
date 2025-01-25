extends Tutorial

class_name Tutorial7CardLayout

func get_name() -> String:
	return "7: Card Layout"

func get_id() -> String:
	return "b7"

func get_description() -> String:
	return "TUTORIAL_7_DESCRIPTION"

func get_image() -> Resource:
	return load("res://tutorial/images/playing_cards.png")

func is_playable() -> bool:
	return true

func get_hint(turn_count: int, event: Event) -> TutorialHint:
	if event is EventPhaseSet:
		return TutorialHint.new(0, "Try right clicking cards\nto get information about them.\nClick End Phase on the left when done.")
	elif event is EventPhaseEventBlock:
		var hint: TutorialHint = TutorialHint.new(0, "Try right clicking cards different\ncards to get information about them.\nClick End Phase on the left when done.")
		hint.exec = complete_tutorial
		return hint
	return null
