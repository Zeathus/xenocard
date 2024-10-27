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
	$Panel/Picture.texture = card.get_image()
	match card.get_original_type():
		Enum.Type.BATTLE:
			$Panel/PictureBorder.color = Color.DARK_RED
		Enum.Type.EVENT:
			$Panel/PictureBorder.color = Color.GOLDENROD
		Enum.Type.SITUATION:
			$Panel/PictureBorder.color = Color.ROYAL_BLUE
	$Panel/Name.text = card.get_name().replace("\n", " ")
	if card.get_original_type() == Enum.Type.BATTLE:
		$Panel/Attribute.visible = true
		$Panel/Attribute.set_attribute(card.get_original_attribute())
		$Panel/TypeBattle.visible = true
		$Panel/Type.visible = false
		$Panel/TypeBattle.text = "Battle"
		if card.get_original_attack_type() != Enum.AttackType.NONE:
			$Panel/TypeBattle.text += " | %s" % Enum.get_attack_type_name(card.get_original_attack_type())
		$Panel/Stat2.visible = true
		if card.get_original_attribute() == Enum.Attribute.WEAPON:
			$Panel/Stat1.visible = false
			if card.get_original_attack_type() == Enum.AttackType.NONE:
				$Panel/Stat2.visible = false
			else:
				$Panel/Stat2.text = "ATK %d " % card.get_original_atk()
		else:
			$Panel/Stat1.visible = true
			$Panel/Stat1.text = " HP %d" % card.get_original_max_hp()
			$Panel/Stat2.text = "ATK %d " % card.get_original_atk()
	else:
		$Panel/Attribute.visible = false
		$Panel/TypeBattle.visible = false
		$Panel/Type.visible = true
		if card.get_original_type() == Enum.Type.EVENT:
			$Panel/Type.text = "Event"
		elif card.get_original_type() == Enum.Type.SITUATION:
			$Panel/Type.text = "Situation"
		$Panel/Stat1.visible = false
		$Panel/Stat2.visible = false
	$Panel/Cost.text = "Cost: %d" % card.get_original_cost()
	var field_icons: Array[Node2D] = [
		$Panel/Field1, $Panel/Field2,
		$Panel/Field3, $Panel/Field4
	]
	for i in range(len(field_icons)):
		var field = card.get_original_field_requirements()
		if len(field) > i:
			field_icons[i].visible = true
			field_icons[i].set_attribute(field[i])
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
