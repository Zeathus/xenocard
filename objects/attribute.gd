extends Node2D

func set_attribute(attr: Card.Attribute):
	if attr != Card.Attribute.ANY:
		$Icon.visible = true
		$Icon.texture = Card.get_attribute_icon(attr)
	else:
		$Icon.visible = false
