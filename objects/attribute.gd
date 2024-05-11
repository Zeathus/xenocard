extends Node2D

func set_attribute(attr: int):
	if attr != Attribute.ANY:
		$Icon.visible = true
		$Icon.texture = Card.get_attribute_icon(attr)
	else:
		$Icon.visible = false
