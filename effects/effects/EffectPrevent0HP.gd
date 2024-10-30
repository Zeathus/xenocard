extends Effect

class_name EffectPrevent0HP

func take_set_damage(game_board: GameBoard, attacker: Card, damage: int, source: Damage) -> int:
	if damage >= target.hp:
		damage = target.hp - 1
	return damage
