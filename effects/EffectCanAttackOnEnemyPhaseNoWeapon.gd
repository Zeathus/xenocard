extends Effect

class_name EffectCanAttackOnEnemyPhaseNoWeapon

func can_attack_on_enemy_phase() -> bool:
	return card.equipped_weapon == null
