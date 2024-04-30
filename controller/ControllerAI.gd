extends Controller

class_name ControllerAI

func _handle_request(action: Action) -> bool:
	match action:
		Action.END_PHASE:
			# End Phase is always checked last, so if this is
			# reached, other requests like SET or MOVE have
			# been denied, so no further actions are taken.
			return true
		Action.SET:
			if do_set_battle_card():
				return true
			if do_set_weapon_card():
				return true
			if do_set_situation_card():
				return true
		Action.EVENT, Action.BLOCK:
			pass
		Action.MOVE:
			if do_move_card():
				return true
	return false

func do_set_battle_card() -> bool:
	var free_zone: int = -1
	for i in range(4):
		if player.field.get_card(Card.Zone.STANDBY, i) == null:
			free_zone = i
			break
	if free_zone == -1:
		return false
	var best_card: Card = null
	var best_score: int = 0
	for card in player.hand.cards:
		if card.type != Card.Type.BATTLE or card.attribute == Card.Attribute.WEAPON:
			continue
		if not card.selectable(game_board):
			continue
		var score: int = get_base_score(card)
		score += card.max_hp
		score += get_atk_score(card)
		if score > best_score:
			best_card = card
			best_score = score
	if best_score > 0:
		response_args = [best_card, Card.Zone.STANDBY, free_zone]
		return true
	return false

func do_set_weapon_card() -> bool:
	var best_holder: Card = null
	var best_card: Card = null
	var best_score: int = 0
	for card in player.hand.cards:
		if card.type != Card.Type.BATTLE or card.attribute != Card.Attribute.WEAPON:
			continue
		if not card.selectable(game_board):
			continue
		for holder in player.field.get_battler_cards():
			if not holder.can_equip(card):
				continue
			if holder.equipped_weapon:
				continue
			var score: int = get_base_score(card)
			score += holder.hp
			if card.atk != 0:
				score += get_atk_score(card) - get_atk_score(holder)
			else:
				score += 3
			if score > best_score:
				best_holder = holder
				best_card = card
				best_score = score
	if best_score > 0:
		response_args = [best_card, best_holder.zone, best_holder.zone_index]
		return true
	return false

func do_set_situation_card() -> bool:
	if len(player.field.get_standby_cards()) >= 4:
		return false
	return false

func do_move_card() -> bool:
	var best_card: Card = null
	var best_zone: Card.Zone = Card.Zone.NONE
	var best_index: int = -1
	var best_score: int = 0
	for card in player.field.get_battler_cards():
		if not card.selectable(game_board):
			continue
		var current_score = get_zone_score(card, card.zone, card.zone_index)
		for zone in [Card.Zone.BATTLEFIELD, Card.Zone.STANDBY]:
			if zone == Card.Zone.STANDBY and zone == card.zone:
				continue
			for index in range(4):
				if zone == card.zone and index == card.zone_index:
					continue
				var score = get_zone_score(card, zone, index)
				var occupant: Card = player.field.get_card(zone, index)
				if occupant and score <= get_zone_score(occupant, zone, index):
					continue
				if score > best_score and score > current_score:
					best_card = card
					best_zone = zone
					best_index = index
					best_score = score
	if best_score > 0:
		response_args = [best_card, best_zone, best_index]
		return true
	return false

func get_base_score(card: Card) -> int:
	var score: int = -card.get_cost()
	return score

func get_atk_score(card: Card) -> int:
	var score: int = 0
	match card.get_target():
		Card.Target.HAND:
			score += card.get_atk() / 2
		Card.Target.BALLISTIC:
			score += card.get_atk()
		Card.Target.SPREAD:
			score += card.get_atk() * 2
		Card.Target.HOMING:
			score += card.get_atk()
	return score

func get_zone_score(card: Card, zone: Card.Zone, index: int) -> int:
	var score: int = 0
	var enemy_field: GameField = player.get_enemy().field
	if zone == Card.Zone.BATTLEFIELD:
		match card.get_target():
			Card.Target.HAND:
				if index <= 1:
					# Hand cards should be in the front if not in standby
					var target = enemy_field.get_card(zone, (index + 1) % 2)
					if target != null:
						var damage = card.get_atk_against(target)
						if damage >= target.hp:
							score += 10
						else:
							score += damage
					else:
						score -= 4
					score += card.hp
				else:
					# No need to have a hand card in the back
					score -= 2
			Card.Target.BALLISTIC:
				var target = enemy_field.get_card(zone, (index + 1) % 2)
				if target == null:
					target = enemy_field.get_card(zone, 2 + ((index + 1) % 2))
				if target != null:
					var damage = card.get_atk_against(target)
					if damage >= target.hp:
						score += 10
					else:
						score += damage
				else:
					var damage = card.get_atk()
					score += damage
					if damage >= player.get_enemy().deck.size() - 1:
						score += 100
				if index <= 1:
					score /= 2
				else:
					score += 1
			Card.Target.SPREAD:
				for target in enemy_field.get_battlefield_cards():
					var damage = card.get_atk_against(target)
					if damage >= target.hp:
						score += 10
					else:
						score += damage
				if index <= 1:
					score /= 3
			Card.Target.HOMING:
				var damage = card.get_atk()
				score += damage
				if index <= 2:
					score /= 2
				if damage >= player.get_enemy().deck.size() - 1:
					score += 100
	else:
		if card.attribute == Card.Attribute.HUMAN:
			score += 2
	return score
