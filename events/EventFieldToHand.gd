extends Event

class_name EventFieldToHand

var card: Card

func _init(_game_board: GameBoard, _card: Card):
	super(_game_board)
	card = _card

func get_name() -> String:
	return "FieldToHand"

func on_start():
	broadcast()
	if card.equipped_weapon:
		queue_event(EventDestroy.new(game_board, card, card.equipped_weapon, Damage.new(Damage.EFFECT | Damage.DISCARD)))
	var position = card.instance.global_position
	card.owner.field.remove_card(card)
	card.owner.hand.add_card(card)
	card.instance.global_position = position
	queue_event(EventAnimation.new(game_board,
		AnimationAddToHand.new(card.instance, card.owner.hand)
	))

func on_finish():
	card.owner.hand.refresh()

func process(delta):
	if pass_to_child("process", [delta]):
		return
	finish()

func broadcast():
	if game_board.is_server():
		for p: Player in [game_board.get_turn_player(), game_board.get_turn_enemy()]:
			var args: Array = [card.get_online_id(p.id == 1)]
			p.controller.broadcast_event(get_name(), args)
