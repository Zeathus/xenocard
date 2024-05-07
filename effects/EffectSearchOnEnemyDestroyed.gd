extends CardEffect

class_name EffectSearchOnEnemyDestroyed

var filter: CardFilter

func post_init():
	filter = CardFilter.new(param)

func on_destroy(destroyed: Card, source: Damage):
	if destroyed.owner == card.owner:
		return
	push_event(true)

func effect():
	events.push_back(EventSearch.new(game_board, card.owner, filter, "Select a card to add to your hand"))
