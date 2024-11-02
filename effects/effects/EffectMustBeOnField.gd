extends Effect

class_name EffectMustBeOnField

var filter: CardFilter

func post_init():
	filter = CardFilter.new(param)

func set_requirements():
	for c in parent.host.owner.field.get_all_cards():
		if filter.is_valid(parent.host.owner, c):
			return true
	return false
