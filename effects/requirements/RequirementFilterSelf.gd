extends Requirement

class_name RequirementFilterSelf

var filter: CardFilter

func post_init():
	filter = CardFilter.new(param)

func met(variables: Dictionary = {}) -> bool:
	return filter.is_valid(effect.host.owner, effect.host, variables)
