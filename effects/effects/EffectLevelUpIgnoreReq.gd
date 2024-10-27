extends EffectLevelUp

class_name EffectLevelUpIgnoreReq

func get_field_requirements(req: Array[Enum.Attribute]) -> Array[Enum.Attribute]:
	for c in card.owner.field.get_battlefield_cards():
		if filter.is_valid(card.owner, c):
			return []
	return super.get_field_requirements(req)
