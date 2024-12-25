extends Event

class_name EventOnlineClient

var client: TCGClient

func _init(_game_board: GameBoard, _client: TCGClient):
	client = _client
	super(_game_board)

func get_name() -> String:
	return "OnlineClient"

func on_start():
	pass

func on_finish():
	pass

func process(delta):
	if pass_to_child("process", [delta]):
		return
	if client.events.size() > 0:
		fetch_event(client.events.pop_front())

func fetch_event(event_data: String):
	var args: PackedStringArray = event_data.split(",")
	match args[0]: # Event type
		"DrawCard":
			var player: Player = game_board.players[int(args[1])]
			if len(args) > 2:
				player.deck.top().set_id(args[2])
			queue_event(EventDrawCard.new(game_board, player))
