extends CardEffect

class_name EffectDiscardWeaponAfterAttack

func after_attack(targets):
	var holder = get_user()
	if holder.equipped_weapon:
		events.push_back(EventDestroy.new(card.owner.game_board, card, holder.equipped_weapon, Card.DamageSource.EFFECT))
		holder.unequip()
