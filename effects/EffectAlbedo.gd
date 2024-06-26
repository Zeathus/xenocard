extends CardEffect

class_name EffectAlbedo

# When this card is alone on your battlefield at the end of your move phase,
# add the number of cards in your junk pile to its ATK until your adjust phase.
# Afterwards, the cards in the junk pile are removed from the game.

func after_move_phase():
	if card.zone != Enum.Zone.BATTLEFIELD:
		return
	for c in card.owner.field.get_battlefield_cards():
		if c != card:
			return
	push_event()

func effect():
	var atk_effect = EffectModifyATK.new(game_board, card, "%d" % card.owner.junk.size())
	atk_effect.duration = 1
	card.applied_effects.push_back(atk_effect)
	card.owner.junk.clear()
