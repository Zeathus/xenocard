extends Node2D

func set_attribute(attr: Enum.Attribute):
	if attr != Enum.Attribute.ANY:
		$Icon.visible = true
		$Icon.texture = Enum.get_attribute_icon(attr)
	else:
		$Icon.visible = false
