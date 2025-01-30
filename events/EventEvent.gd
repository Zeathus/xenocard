extends Event

class_name EventEvent

var player: Player
var card: Card
var block: bool

func _init(_game_board: GameBoard, _card: Card, _block: bool = false):
	player = _card.owner
	card = _card
	block = _block
	super(_game_board)

func get_name() -> String:
	return "Event"

func on_start():
	if card.selectable(game_board):
		broadcast()
		play(card)

func on_finish():
	pass

func process(delta):
	if pass_to_child("process", [delta]):
		return
	finish()

func play(card: Card):
	if card.zone == Enum.Zone.HAND:
		#if card.instance.is_face_down() and game_board.online_mode == 0:
			#for i in range(player.hand.size()):
				#if player.hand.cards[i].instance.is_face_down():
					#if player.hand.cards.find(card) <= i:
						#break
					#player.hand.cards.erase(card)
					#player.hand.cards.insert(i, card)
					#player.hand.refresh()
					#break
		var cost_to_pay = card.get_cost()
		var cost_paid: int = player.pay_cost(cost_to_pay)
		for i in range(cost_paid):
			queue_event(EventPayCost.new(game_board, player))
	card.revealed = true
	if card.instance.is_face_down():
		queue_event(EventAnimation.new(game_board, AnimationFlip.new(card)))
	queue_event(EventAnimation.new(game_board, AnimationEffectStart.new(card)))
	if card.get_type() == Enum.Type.EVENT:
		queue_event(EventCounterPrompt.new(game_board, player.get_enemy(), card))
	card.trigger_effects(Enum.Trigger.ACTIVATE, self, {"block": block})
	queue_event(EventAnimation.new(game_board, AnimationEffectEnd.new(card)))

func broadcast():
	if game_board.is_server():
		player.get_enemy().controller.send_identity(card.get_online_id(player.id == 0), card.data.get_full_id())
		for p: Player in [game_board.get_turn_player(), game_board.get_turn_enemy()]:
			var args: Array = [card.get_online_id(p.id == 1), "1" if block else "0"]
			p.controller.broadcast_event(get_name(), args)
