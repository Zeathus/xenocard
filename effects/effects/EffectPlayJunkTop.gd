extends Effect

class_name EffectPlayJunkTop

var filter: CardFilter

func post_init():
	filter = CardFilter.new(param)

func effect(variables: Dictionary = {}):
	var card_to_set: Card = parent.host.owner.junk.top()
	if card_to_set:
		var zone: Enum.Zone = Enum.Zone.NONE
		var zone_index: int = -1
		if card_to_set.get_type() == Enum.Type.BATTLE:
			zone = Enum.Zone.STANDBY
			for i in range(4):
				if card_to_set.owner.field.get_card(Enum.Zone.STANDBY, i) == null:
					zone_index = i
					break
		elif card_to_set.get_type() == Enum.Type.SITUATION:
			zone = Enum.Zone.SITUATION
			for i in range(4):
				if card_to_set.owner.field.get_card(Enum.Zone.SITUATION, i) == null:
					zone_index = i
					break
		if zone != Enum.Zone.NONE and zone_index >= 0:
			var set_event = EventAutoSet.new(game_board, card_to_set.owner, card_to_set, zone, zone_index)
			parent.events.push_back(set_event)

func has_valid_targets(variables: Dictionary = {}) -> bool:
	if parent.host.owner.junk.size() == 0:
		return false
	var card_to_set: Card = parent.host.owner.junk.top()
	if filter.is_valid(parent.host.owner, card_to_set, {"self": parent.host}):
		if card_to_set.get_type() == Enum.Type.BATTLE:
			for i in range(4):
				if card_to_set.owner.field.get_card(Enum.Zone.STANDBY, i) == null:
					return true
		elif card_to_set.get_type() == Enum.Type.SITUATION:
			for i in range(4):
				if card_to_set.owner.field.get_card(Enum.Zone.SITUATION, i) == null:
					return true
	return false
