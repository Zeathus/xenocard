extends Tutorial

class_name Tutorial14TheBattlePhase

func get_name() -> String:
	return "14: The Battle Phase"

func get_id() -> String:
	return "b14"

func get_description() -> String:
	return "TUTORIAL_14_DESCRIPTION"

func is_playable() -> bool:
	return true

func get_hint(turn_count: int, event: Event) -> TutorialHint:
	match turn_count:
		3:
			if event is EventPhaseSet:
				return TutorialHint.new(0, "Your battlefield has every attack type.\nClick \"End Phase\" to start the Battle Phase.")
			elif event is EventAttack and event.attacker.get_attack_type() == Enum.AttackType.HAND:
				return TutorialHint.new(1, "First, your Drone attacks with its hand attack type.")
			elif event is EventAttack and event.attacker.get_attack_type() == Enum.AttackType.BALLISTIC:
				return TutorialHint.new(1, "Second, your Soldier attacks with its ballistic attack type.")
			elif event is EventAttack and event.attacker.get_attack_type() == Enum.AttackType.SPREAD:
				return TutorialHint.new(1, "Third, your Gremlin attacks with its spread attack type.")
			elif event is EventAttack and event.attacker.get_attack_type() == Enum.AttackType.HOMING:
				return TutorialHint.new(1, "Finally, your Hydra attacks with its homing attack type.")
			elif event is EventPhaseAdjust:
				var hint: TutorialHint = TutorialHint.new(1, "Battle cards will always attack in this order of attack types.")
				hint.exec = complete_tutorial
				return hint
	return null
