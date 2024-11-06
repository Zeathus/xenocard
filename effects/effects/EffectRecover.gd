extends Effect

class_name EffectRecover

var amount: String

func post_init():
	amount = Formula.prepare(param, target, parent.get_game_board())

func effect(variables: Dictionary = {}):
	var recovered = Formula.calc(amount, target, parent.get_game_board())
	parent.events.push_back(EventRecover.new(target.owner.game_board, target.owner, recovered))

func has_valid_targets(variables: Dictionary = {}) -> bool:
	return parent.host.owner.lost.size() > 0
