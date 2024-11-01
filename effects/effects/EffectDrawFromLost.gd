extends Effect

class_name EffectDrawFromLost

var amount: int

func post_init():
	amount = int(param)

func effect():
	for i in range(amount):
		events.push_back(EventDrawCardFromLost.new(game_board, card.owner))

func has_valid_targets(variables: Dictionary = {}) -> bool:
	return card.owner.lost.size() >= amount
