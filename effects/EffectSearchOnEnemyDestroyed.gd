extends CardEffect

class_name EffectSearchOnEnemyDestroyed

var filter: CardFilter

func post_init():
	filter = CardFilter.new(param)

func on_destroy(destroyed: Card, source: Damage):
	if destroyed.owner == card.owner:
		return
	events.push_back(EventConfirm.new(
		game_board,
		card.owner,
		get_confirm_message(),
		EventSearch.new(game_board, card.owner, filter, ""),
		Callable(),
		get_help_text()
	))
