extends Effect

class_name EffectRevealHand

var players: Array

func post_init():
	players = [false, false]
	if param == "self":
		players[0] = true
	elif param == "enemy":
		players[1] = true
	elif param == "both" or param == "all":
		players = [true, true]

func reveal_hand(player: Player):
	if players[0] and player == parent.host.owner:
		return true
	if players[1] and player == parent.host.owner.get_enemy():
		return true
	return false

func get_effect_score(variables: Dictionary = {}) -> int:
	var score = 0
	if players[0]:
		score -= 2
	if players[1]:
		score += 4
	return score

func effect(variables: Dictionary = {}):
	if game_board.is_server():
		if players[0]:
			for card in game_board.players[0].hand.cards:
				game_board.players[1].controller.send_identity(card.get_online_id(true), card.data.get_full_id(), true)
		if players[1]:
			for card in game_board.players[1].hand.cards:
				game_board.players[0].controller.send_identity(card.get_online_id(false), card.data.get_full_id(), true)
	elif game_board.is_client():
		if players[1]:
			for card in game_board.players[1].hand.cards:
				parent.events.push_back(EventIdentity.new(game_board, "", "SYS/anon", true))
