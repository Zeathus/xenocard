extends Effect

class_name EffectNeutralize

var filter: CardFilter = null

func post_init():
	filter = CardFilter.new(param)

func effect(variables: Dictionary = {}):
	parent.events.push_back(EventDestroy.new(parent.get_game_board(), parent.host, variables["countered"], Damage.new(Damage.EFFECT | Damage.DESTROY)))
