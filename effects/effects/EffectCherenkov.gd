extends Effect

class_name EffectCherenkov

# If this card is destroyed, and the top card of your junk pile is a
# {Human}, {Realian} or {Machine}, play that card in this card's place
# during the adjust phase. The new card will have 1 HP.

var top_card: Card

func effect(variables: Dictionary = {}):
	top_card = parent.host.owner.junk.top()
	if top_card == null or top_card.get_name() == parent.host.get_name():
		return
	if top_card.get_attribute() not in [Enum.Attribute.HUMAN, Enum.Attribute.REALIAN, Enum.Attribute.MACHINE]:
		return
	game_board.add_phase_effect(Enum.Phase.ADJUST,
		EffectPlayToZoneWith1HP.new(parent, game_board, top_card, "%d,%d" % [parent.host.zone, parent.host.zone_index])
	)
