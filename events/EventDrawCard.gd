extends Event

class_name EventDrawCard

var player: Player
var card: Card

func _init(_game_board: GameBoard, _player: Player):
	super(_game_board)
	player = _player

func get_name() -> String:
	return "DrawCard"

func on_start():
	for c in game_board.get_all_field_cards():
		for e in c.get_effects(Enum.Trigger.PASSIVE):
			if e.redirects_draw_to_lost(player):
				broadcast_empty()
				queue_event(EventDrawCardFromLost.new(game_board, player))
				return
	card = player.draw()
	if card == null:
		broadcast_empty()
		return
	broadcast()
	game_board.prepare_card(card)
	player.hand.add_card(card)
	var flip = card.instance.is_face_up()
	if flip:
		card.instance.turn_down()
	card.instance.global_position = player.field.get_deck_node().global_position
	queue_event(EventAnimation.new(game_board,
		AnimationAddToHand.new(card.instance, player.hand, flip)
	))
	game_board.play_se("click2", 5)

func on_finish():
	player.hand.refresh()

func process(delta):
	if pass_to_child("process", [delta]):
		return
	finish()

func broadcast():
	if game_board.is_server():
		player.controller.broadcast_event(get_name(), [player, card.data.get_full_id()])
		if player.reveal_hand:
			player.get_enemy().controller.broadcast_event(get_name(), [player, card.data.get_full_id()])
		else:
			player.get_enemy().controller.broadcast_event(get_name(), [player])

func broadcast_empty():
	if game_board.is_server():
		player.controller.broadcast_event(get_name(), [player])
		player.get_enemy().controller.broadcast_event(get_name(), [player])

func stop_on_game_end() -> bool:
	return false
