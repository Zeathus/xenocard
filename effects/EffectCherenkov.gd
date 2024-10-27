extends CardEffect

class_name EffectCherenkov

# If this card is destroyed, and the top card of your junk pile is a
# {Human}, {Realian} or {Machine}, play that card in this card's place
# during the adjust phase. The new card will have 1 HP.

var top_card: Card

func on_destroyed(attacker: Card, source: Damage):
	if not source.normal_attack():
		return
	top_card = card.owner.junk.top()
	if top_card == null or top_card.get_name() == "Cherenkov":
		return
	if top_card.get_attribute() not in [Enum.Attribute.HUMAN, Enum.Attribute.REALIAN, Enum.Attribute.MACHINE]:
		return
	push_event()

func effect():
	game_board.add_phase_effect(Enum.Phase.ADJUST,
		EffectPlayToZoneWith1HP.new(game_board, top_card, "%d,%d" % [card.zone, card.zone_index])
	)
