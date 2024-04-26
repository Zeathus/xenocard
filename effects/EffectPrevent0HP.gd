extends CardEffect

class_name EffectPrevent0HP

func take_set_damage(game_board: GameBoard, attacker: Card, damage: int, source: Damage) -> int:
	if damage >= card.hp:
		damage = card.hp - 1
	return damage
