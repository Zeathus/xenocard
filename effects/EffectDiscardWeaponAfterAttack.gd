extends CardEffect

class_name EffectDiscardWeaponAfterAttack

func after_attack(targets):
	var holder = get_user()
	if holder.equipped_weapon:
		push_event()

func effect():
	var holder = get_user()
	events.push_back(EventDestroy.new(card.owner.game_board, card, holder.equipped_weapon, Damage.new(Damage.EFFECT | Damage.DISCARD)))
	holder.unequip()
