extends Controller

class_name ControllerAI

var last_can_end_move_phase: bool = true
var delay: float = 0.5

func _prepare_handling(actions: Array[Action]):
	if delay > 0:
		OS.delay_msec(floor(delay * 1000))

func _handle_request(action: Action, args: Array) -> bool:
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
			if do_activate(action == Action.BLOCK):
				return true
		Action.MOVE:
			if do_move_card():
				return true
		Action.CONFIRM:
			response_args = [true]
			return true
		Action.TARGET:
			if do_target(args[0], args[1], args[2]):
				return true
		Action.SEARCH:
			if do_search(args[0]):
				return true
		Action.SEARCH_JUNK:
			if do_search(args[0], true):
				return true
		Action.DISCARD:
			if do_discard(args[0]):
				return true
		Action.COUNTER:
			if do_counter(args[0]):
				return true
		Action.MULLIGAN:
			if do_mulligan(args[0]):
				return true
	return false

func do_set_battle_card() -> bool:
	var best_card: Card = null
	var best_score: int = 0
	var best_zone: Enum.Zone = Enum.Zone.NONE
	var best_index: int = -1
	var best_targets: Array[Card] = []
	for card in player.hand.cards:
		if card.get_type() != Enum.Type.BATTLE or card.get_attribute() == Enum.Attribute.WEAPON:
			continue
		var score: int = 0
		var to_select: Array[Callable] = []
		var targets: Array[Card] = []
		for e in card.effects:
			e.targets_to_select_for_set(to_select)
		for i in to_select:
			for target in player.field.get_battler_cards():
				if not target in targets and i.call(target):
					if get_atk_score(target) < get_atk_score(card) or target.get_max_hp() > card.hp - 1:
						targets.push_back(target)
						break
			if targets.size() == to_select.size():
				break
		if targets.size() < to_select.size():
			continue
		for t in targets:
			score -= t.hp / 2
			score -= get_atk_score(t) / 2
		var free_zones: Array
		for zone in [Enum.Zone.STANDBY, Enum.Zone.BATTLEFIELD]:
			for i in range(4):
				if card.can_play(game_board, zone, i):
					free_zones.push_back([zone, i])
		if free_zones.is_empty():
			continue
		if not card.selectable(game_board):
			continue
		score += get_base_score(card)
		score += card.get_max_hp()
		score += get_atk_score(card)
		if score > best_score:
			best_card = card
			best_score = score
			best_targets = targets
			best_zone = free_zones[0][0]
			best_index = free_zones[0][1]
			var best_zone_score = get_zone_score(card, best_zone, best_index)
			for i in range(1, len(free_zones)):
				var zone_score = get_zone_score(card, free_zones[i][0], free_zones[i][1])
				if zone_score > best_zone_score:
					best_zone = free_zones[i][0]
					best_index = free_zones[i][1]
					best_zone_score = zone_score
	if best_score > 0:
		response_args = [best_card, best_zone, best_index, best_targets]
		return true
	return false

func do_set_weapon_card() -> bool:
	var best_holder: Card = null
	var best_card: Card = null
	var best_score: int = 0
	for card in player.hand.cards:
		if card.get_type() != Enum.Type.BATTLE or card.get_attribute() != Enum.Attribute.WEAPON:
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
			if card.get_atk() != 0:
				var atk_score_diff = get_atk_score(card) - get_atk_score(holder)
				if atk_score_diff <= 0:
					score = 0
				else:
					score += atk_score_diff
			else:
				score += 3
			if score > best_score:
				best_holder = holder
				best_card = card
				best_score = score
	if best_score > 0:
		var targets: Array[Card] = []
		response_args = [best_card, best_holder.zone, best_holder.zone_index, targets]
		return true
	return false

func do_set_situation_card() -> bool:
	if len(player.field.get_situation_cards()) >= 4:
		return false
	for card in player.hand.cards:
		if card.get_type() != Enum.Type.SITUATION:
			continue
		if not card.selectable(game_board):
			continue
		var exists: bool = false
		for other in player.field.get_situation_cards():
			if other.get_name() == card.get_name():
				exists = true
				break
		if not exists:
			for i in range(4):
				if player.field.get_card(Enum.Zone.SITUATION, i) == null:
					var targets: Array[Card] = []
					response_args = [card, Enum.Zone.SITUATION, i, targets]
					return true
	return false

func do_activate(blocking: bool):
	var best_card: Card = null
	var best_score: int = 0
	for card in player.hand.cards:
		if card.get_type() != Enum.Type.EVENT:
			continue
		var score: int = 0
		if not card.selectable(game_board):
			continue
		score += get_base_score(card)
		score += get_effect_score(card, Enum.Trigger.ACTIVATE)
		if score > best_score:
			best_card = card
			best_score = score
	if best_score > 0:
		response_args = [best_card]
		return true
	return false

func do_counter(chain: Array[Card]):
	var best_card: Card = null
	var best_score: int = 0
	for card in player.hand.cards:
		if card.get_type() != Enum.Type.EVENT:
			continue
		if card in chain:
			continue
		if not card.has_counter_effect():
			continue
		var score: int = 0
		if not card.selectable(game_board):
			continue
		score += 10
		if score > best_score:
			best_card = card
			best_score = score
	if best_score > 0:
		response_args = [best_card]
		return true
	return false

func do_move_card() -> bool:
	# Check if move phase can be ended.
	# Right now this can only be prevented by situation cards
	# that force cards to the battlefield, so assume this is
	# always the reason, and make it move to the battlefield.
	var can_end_move_phase: bool = true
	for card in game_board.get_all_field_cards():
		for e in card.get_effects(Enum.Trigger.PASSIVE):
			if not e.can_end_phase(Enum.Phase.MOVE, player):
				can_end_move_phase = false
				break
	if not last_can_end_move_phase and can_end_move_phase:
		# We just fulfilled the conditions to end the phase, just end it
		last_can_end_move_phase = true
		return false
	last_can_end_move_phase = can_end_move_phase
	# Decide the best card to move and where to
	var best_card: Card = null
	var best_zone: Enum.Zone = Enum.Zone.NONE
	var best_index: int = -1
	var best_score: int = 0
	for card in player.field.get_battler_cards():
		if not card.selectable(game_board):
			continue
		var current_score = get_zone_score(card, card.zone, card.zone_index)
		for zone in [Enum.Zone.BATTLEFIELD, Enum.Zone.STANDBY]:
			if zone == Enum.Zone.STANDBY and zone == card.zone:
				# Do not move cards amongst the standby area
				continue
			if not can_end_move_phase and zone == Enum.Zone.STANDBY:
				# Do not move cards back to standby
				continue
			for index in range(4):
				if zone == card.zone and index == card.zone_index:
					continue
				var score = get_zone_score(card, zone, index)
				var occupant: Card = player.field.get_card(zone, index)
				if occupant and score <= get_zone_score(occupant, zone, index):
					continue
				if not can_end_move_phase and occupant == null:
					if zone == Enum.Zone.BATTLEFIELD and card.zone == Enum.Zone.STANDBY:
						# Enforce moving to unoccupied battlefield spaces when phase can't be ended
						score += 100
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
	match card.get_attack_type():
		Enum.AttackType.HAND:
			score += card.get_atk() / 2
		Enum.AttackType.BALLISTIC:
			score += card.get_atk()
		Enum.AttackType.SPREAD:
			score += card.get_atk() * 2
		Enum.AttackType.HOMING:
			score += card.get_atk()
	if card.can_attack_on_enemy_phase():
		score *= 2
	score /= card.get_atk_time()
	return score

func get_zone_score(card: Card, zone: Enum.Zone, index: int) -> int:
	var score: int = 0
	var enemy_field: GameField = player.get_enemy().field
	if zone == Enum.Zone.BATTLEFIELD:
		match card.get_attack_type():
			Enum.AttackType.HAND:
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
					if player.field.get_card(zone, index + 2) != null:
						# Hand cards protect cards in the back row
						score += card.hp
				else:
					# No need to have a hand card in the back
					score -= 2
			Enum.AttackType.BALLISTIC:
				var target = enemy_field.get_card(zone, (index + 1) % 2)
				if target == null:
					target = enemy_field.get_card(zone, 2 + ((index + 1) % 2))
				if target != null:
					var damage = card.get_atk_against(target)
					if damage >= target.hp:
						score += 10
					elif damage >= target.hp / 2:
						score += 2 + damage
					elif damage >= target.hp / 3:
						score += 1 + damage
					elif damage >= target.hp / 4:
						score += damage - 1
					elif damage >= target.hp / 5:
						score += damage - 2
					else:
						score += damage - 3
				else:
					var damage = card.get_atk()
					score += damage
					if enemy_field.get_battlefield_cards().is_empty():
						score += 2
					if damage >= player.get_enemy().deck.size() - 1:
						score += 100
				if index <= 1:
					score /= 2
				else:
					score += 1
			Enum.AttackType.SPREAD:
				for target in enemy_field.get_battlefield_cards():
					var damage = card.get_atk_against(target)
					if damage >= target.hp:
						score += 10
					else:
						score += damage
				if index <= 1:
					score /= 3
			Enum.AttackType.HOMING:
				var damage = card.get_atk()
				score += damage
				if index <= 2:
					score /= 2
				if damage >= player.get_enemy().deck.size() - 1:
					score += 100
		if card.zone == Enum.Zone.STANDBY and len(player.field.get_standby_cards()) >= 4:
			if player.field.get_card(zone, index) == null:
				score += 10
	else:
		if card.get_attribute() == Enum.Attribute.HUMAN:
			score += 2
		if card.zone == Enum.Zone.BATTLEFIELD and len(player.field.get_standby_cards()) >= 3:
			if player.field.get_card(zone, index) == null:
				score -= 10
	return score

func get_effect_score(card: Card, trigger: Enum.Trigger):
	var variables: Dictionary = {"self": card}
	var score = 0
	for effect in card.get_effects(trigger, variables):
		for e in effect.effects:
			score += e.get_effect_score(variables)
	return score

func get_target_score(card: Card, effect: CardEffect):
	var score = 0
	for e in effect.effects:
		score += e.get_target_score(card)
	return score

func do_target(filter: CardFilter, targeted: Array[Card], effect: CardEffect) -> bool:
	var best_target: Card = null
	var best_score: int = 0
	for card in game_board.get_all_field_cards():
		if card in targeted:
			continue
		if filter.is_valid(player, card):
			var score: int = get_target_score(card, effect)
			if best_target == null or score > best_score:
				best_target = card
				best_score = score
	if best_target:
		response_args = [best_target]
	return true

func do_search(filter: CardFilter, junk: bool = false):
	var best_target: Card = null
	var best_index: int = -1
	var best_score: int = 0
	var pile: Deck = player.junk if junk else player.deck
	for i in range(len(pile.cards)):
		var card: Card = pile.cards[i]
		if filter.is_valid(player, card):
			var score: int = 10
			if player.hand.cards.all(func(x): return x.get_name() != card.get_name()):
				score += 10
			if best_target == null or score > best_score:
				best_target = card
				best_index = i
				best_score = score
	if best_target:
		response_args = [best_index, best_target]
	else:
		response_args = [-1, null]
	return true

func do_discard(filter: CardFilter):
	var best_target: Card = null
	var best_score: int = 0
	for card in player.game_board.get_all_field_cards() + player.hand.cards + player.get_enemy().hand.cards:
		if filter.is_valid(player, card):
			var score: int = 10
			if best_target == null or score > best_score:
				best_target = card
				best_score = score
	if best_target:
		response_args = [best_target]
	else:
		response_args = [null]
	return true

func do_mulligan(remaining: int) -> bool:
	var score: int = get_starting_hand_score()
	# Require less score with fewer tries remaining
	print("Score: ", score)
	if score < remaining:
		return true
	return false

func get_starting_hand_score() -> int:
	var score: int = 0
	var turn_1_resources: Array[Enum.Attribute] = []
	var cards: Array[Card] = player.hand.cards.duplicate()
	var to_erase: Array[Card] = []
	var playable_humans: int = 0
	for card in cards:
		if card.get_type() != Enum.Type.BATTLE:
			continue
		if len(card.get_field_requirements()) == 0:
			if card.get_attribute() == Enum.Attribute.HUMAN:
				playable_humans += 1
			if card.get_attribute() in turn_1_resources:
				continue
			turn_1_resources.append(card.get_attribute())
			to_erase.push_back(card)
	for card in to_erase:
		cards.erase(card)
	if len(turn_1_resources) > 0:
		score += min(len(turn_1_resources), 2)
		for card in cards:
			if card.get_type() != Enum.Type.BATTLE:
				continue
			if card.get_attribute() == Enum.Attribute.GNOSIS and playable_humans < 2:
				# Do not give 2 points for 1 human + 1 gnosis
				continue
			var req: Array[Enum.Attribute] = card.get_field_requirements()
			if len(req) == 0:
				score += 1
			elif len(req) == 1:
				if req[0] == Enum.Attribute.ANY or req[0] in turn_1_resources:
					score += 1
			elif len(req) == 2:
				if len(turn_1_resources) >= 2 or playable_humans >= 2:
					if req[0] == Enum.Attribute.ANY and req[1] == Enum.Attribute.ANY:
						score += 1
					elif req[0] != Enum.Attribute.ANY and req[1] == Enum.Attribute.ANY:
						if req[0] in turn_1_resources:
							score += 1
					elif req[0] == Enum.Attribute.HUMAN and req[1] == Enum.Attribute.HUMAN:
						if playable_humans >= 2:
							score += 1
	return score
