extends Node2D

class_name CardListRow

signal row_hovered(card: Card)
signal add_card(card: Card)

var card: Card = null
var loaded: bool = false

func get_card() -> Card:
	return card

func set_card(_card: Card):
	card = _card

func load_card():
	if loaded:
		return
	var image_file: String = "res://sprites/card_images/%s/%s.png" % [card.set_name, card.id]
	if ResourceLoader.exists(image_file):
		$Panel/Picture.texture = load(image_file)
	else:
		$Panel/Picture.texture = load("res://sprites/card_images/missing_artwork.png")
		push_error("Failed to find card image '%s'" % image_file)
	match card.type:
		Enum.Type.BATTLE:
			$Panel/PictureBorder.color = Color.DARK_RED
		Enum.Type.EVENT:
			$Panel/PictureBorder.color = Color.GOLDENROD
		Enum.Type.SITUATION:
			$Panel/PictureBorder.color = Color.ROYAL_BLUE
	$Panel/Name.text = card.name.replace("\n", " ")
	if card.type == Enum.Type.BATTLE:
		$Panel/Attribute.visible = true
		$Panel/Attribute.set_attribute(card.attribute)
		$Panel/TypeBattle.visible = true
		$Panel/Type.visible = false
		$Panel/TypeBattle.text = "Battle"
		if card.target != Enum.AttackType.NONE:
			$Panel/TypeBattle.text += " | %s" % Card.get_target_name(card.target)
		$Panel/Stat2.visible = true
		if card.attribute == Enum.Attribute.WEAPON:
			$Panel/Stat1.visible = false
			if card.target == Enum.AttackType.NONE:
				$Panel/Stat2.visible = false
			else:
				$Panel/Stat2.text = "ATK %d " % card.atk
		else:
			$Panel/Stat1.visible = true
			$Panel/Stat1.text = " HP %d" % card.hp
			$Panel/Stat2.text = "ATK %d " % card.atk
	else:
		$Panel/Attribute.visible = false
		$Panel/TypeBattle.visible = false
		$Panel/Type.visible = true
		if card.type == Enum.Type.EVENT:
			$Panel/Type.text = "Event"
		elif card.type == Enum.Type.SITUATION:
			$Panel/Type.text = "Situation"
		$Panel/Stat1.visible = false
		$Panel/Stat2.visible = false
	$Panel/Cost.text = "Cost: %d" % card.cost
	var field_icons: Array[Node2D] = [
		$Panel/Field1, $Panel/Field2,
		$Panel/Field3, $Panel/Field4
	]
	for i in range(len(field_icons)):
		if len(card.field) > i:
			field_icons[i].visible = true
			field_icons[i].set_attribute(card.field[i])
		else:
			field_icons[i].visible = false
	loaded = true

func unload_card():
	pass

func _on_visibility_changed():
	$Area2D.monitorable = visible

func _on_panel_mouse_entered():
	row_hovered.emit(card)

func _on_panel_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == 1:
				add_card.emit(card)
			elif event.button_index == 2:
				add_card.emit(card)
