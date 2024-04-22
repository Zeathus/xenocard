extends CardEffect

class_name EffectCherenkov

# If this card is destroyed, and the top card of your junk pile is a
# {Human}, {Realian} or {Machine}, play that card in this card's place
# during the adjust phase. The new card will have 1 HP.

func on_destroyed(attacker: Card, source: Card.DamageSource):
	var top_card = card.owner.junk.top()
	if top_card == null:
		return
	if top_card.attribute not in [Card.Attribute.HUMAN, Card.Attribute.REALIAN, Card.Attribute.MACHINE]:
		return
	game_board.add_phase_effect(GameBoard.Phase.ADJUST,
		EffectPlayToZoneWith1HP.new(game_board, top_card, "%d,%d" % [card.zone, card.zone_index])
	)
