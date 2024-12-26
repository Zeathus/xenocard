extends Node2D

class_name CardListRow

signal row_hovered(card: CardData)
signal add_card(card: CardData)

var card: CardData = null
var loaded: bool = false

func get_card() -> CardData:
	return card

func set_card(_card: CardData):
	card = _card

func load_card():
	if loaded:
		return
	$Panel/Picture.texture = card.get_baked_image()
	#match card.type:
		#Enum.Type.BATTLE:
			#$Panel/PictureBorder.color = Color.DARK_RED
		#Enum.Type.EVENT:
			#$Panel/PictureBorder.color = Color.GOLDENROD
		#Enum.Type.SITUATION:
			#$Panel/PictureBorder.color = Color.ROYAL_BLUE
	$Panel/Name.text = card.name.replace("\n", " ")
	if card.type == Enum.Type.BATTLE:
		$Panel/Attribute.visible = true
		$Panel/Attribute.set_attribute(card.attribute)
		$Panel/TypeBattle.visible = true
		$Panel/Type.visible = false
		$Panel/TypeBattle.text = "Battle"
		if card.attack_type != Enum.AttackType.NONE:
			$Panel/TypeBattle.text += " | %s" % Enum.get_attack_type_name(card.attack_type)
		$Panel/ATK.visible = true
		$Panel/ATKValue.visible = true
		if card.attribute == Enum.Attribute.WEAPON:
			$Panel/HP.visible = false
			$Panel/HPValue.visible = false
			if card.attack_type == Enum.AttackType.NONE:
				$Panel/ATK.visible = false
				$Panel/ATKValue.visible = false
			else:
				$Panel/ATKValue.text = "%d " % card.atk
		else:
			$Panel/HP.visible = true
			$Panel/HPValue.visible = true
			$Panel/HPValue.text = "%d " % card.max_hp
			$Panel/ATKValue.text = "%d " % card.atk
	else:
		$Panel/Attribute.visible = false
		$Panel/TypeBattle.visible = false
		$Panel/Type.visible = true
		if card.type == Enum.Type.EVENT:
			$Panel/Type.text = "Event"
		elif card.type == Enum.Type.SITUATION:
			$Panel/Type.text = "Situation"
		$Panel/HP.visible = false
		$Panel/HPValue.visible = false
		$Panel/ATK.visible = false
		$Panel/ATKValue.visible = false
	$Panel/Cost.text = "Cost: %d" % card.cost
	var field_icons: Array[Node2D] = [
		$Panel/Field1, $Panel/Field2,
		$Panel/Field3, $Panel/Field4
	]
	for i in range(len(field_icons)):
		var field = card.field
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
