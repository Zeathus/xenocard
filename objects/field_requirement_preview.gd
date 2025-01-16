extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_requirement_and_resources(requirement: Array[Enum.Attribute], resources: Array[Enum.Attribute]) -> void:
	resources = resources.duplicate()
	var attributes: Array[Node2D] = [$Panel/Attribute1, $Panel/Attribute2, $Panel/Attribute3, $Panel/Attribute4]
	if len(requirement) == 0:
		for i in attributes:
			i.visible = false
		$Panel/LabelNone.visible = true
		$Panel.size.x = 330
		$Panel.position.x = -$Panel.size.x / 2
		return
	else:
		$Panel.size.x = 276 + 88 * (len(requirement) - 1)
		$Panel/LabelNone.visible = false
		$Panel.position.x = -$Panel.size.x / 2
	for i in range(4):
		if len(requirement) <= i:
			attributes[i].visible = false
		else:
			attributes[i].set_attribute(requirement[i])
			attributes[i].visible = true
			var yes_node: Sprite2D = attributes[i].find_child("Yes")
			var no_node: Sprite2D = attributes[i].find_child("No")
			if requirement[i] in resources:
				yes_node.visible = true
				no_node.visible = false
				resources.erase(requirement[i])
			elif requirement[i] == Enum.Attribute.ANY and len(resources) > 0:
				yes_node.visible = true
				no_node.visible = false
				resources.pop_back()
			else:
				yes_node.visible = false
				no_node.visible = true
