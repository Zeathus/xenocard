extends Node2D

signal selected(button_index: int)
signal on_hover()

@export var selectable: bool = true
var original_scale: Vector2
var original_z: int
var is_hovering: bool = false
var old_is_hovering: bool = false
var attribute: Enum.Attribute

# Called when the node enters the scene tree for the first time.
func _ready():
	original_scale = $Content.scale
	original_z = z_index

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if old_is_hovering != is_hovering:
		old_is_hovering = is_hovering
		if is_hovering:
			$Content.scale = original_scale * 1.25
			$Back.scale = original_scale * 1.25
			$Content.rotation = -global_rotation
		else:
			$Content.scale = original_scale
			$Back.scale = original_scale
			$Content.rotation = 0
	z_index = original_z
	if is_hovering:
		z_index += 1

func show_card(card: CardData):
	$Content/Background.texture = Enum.get_type_background(card.type)
	$Content/Name.text = ""
	$Content/SmallName.text = ""
	$Content/TwoLineName.text = ""
	var card_name = card.get_name()
	if "\n" in card_name:
		$Content/TwoLineName.text = card_name
	elif len(card_name) <= 9 if Options.locale == "jp" else len(card_name) <= 20:
		$Content/Name.text = card_name
	else:
		$Content/SmallName.text = card_name
	$Content/TypeBattle.visible = (card.type == Enum.Type.BATTLE)
	$Content/TypeOther.visible = (card.type != Enum.Type.BATTLE)
	$Content/Attribute.visible = (card.type == Enum.Type.BATTLE)
	$Content/Stats.visible = (card.type == Enum.Type.BATTLE)
	var expanded_text: String = Keyword.expand_keywords(card.get_text())
	if card.full_art == 2:
		expanded_text = expanded_text.replace("#ffff86", "#909032")
		expanded_text = expanded_text.replace("#c6c6ff", "#415fcf")
	var text_size: int = 34 if Options.locale == "jp" else 36
	while true:
		$Content/Text.text = ""
		$Content/Text.push_font_size(text_size)
		$Content/Text.append_text(expanded_text)
		if $Content/Text.get_content_height() <= $Content/Text.size.y:
			break
		text_size -= 2
	$Content/Text.pop_all()
	$Content/Cost/Value.text = "%d" % card.cost
	$Content/SerialNumber.text = "%s #%03d" % [card.set_name, card.set_id]
	$Content/Rarity.texture = Enum.get_rarity_icon(card.rarity)
	var field_icons: Array[Node2D] = [
		$Content/Field/Value1, $Content/Field/Value2,
		$Content/Field/Value3, $Content/Field/Value4
	]
	for i in range(len(field_icons)):
		var field = card.field
		if len(field) > i:
			field_icons[i].visible = true
			field_icons[i].set_attribute(field[i])
		else:
			field_icons[i].visible = false
	if card.type == Enum.Type.BATTLE:
		attribute = card.attribute
		$Content/Attribute.set_attribute(attribute)
		$Content/Stats/HP/Value.text = "%d" % card.max_hp
		$Content/Stats/Attack/Value.text = "%d" % card.atk
		$Content/Stats/AttackType.text = Enum.get_attack_type_name(card.attack_type)
	else:
		attribute = Enum.Attribute.ANY
		$Content/TypeOther.text = Enum.get_type_name(card.type)
	if card.full_art == 0:
		$Content/PictureFull.texture = null
		$Content/Picture.texture = card.get_image()
	else:
		$Content/Picture.texture = null
		$Content/PictureFull.texture = card.get_image()
	$Content/Artist.text = card.artist
	set_full_art(card.full_art)

func set_full_art(val: int) -> void:
	$Content/Border.visible = val > 0
	$Content/PictureFull.visible = val > 0
	$Content/Picture.visible = val == 0
	$Content/ArtistIcon.visible = true
	$Content/ArtistIconOutlined.visible = val > 0
	var textBorder1 = 0 if val == 0 else 12
	var textBorder2 = 0 if val == 0 else 8
	var shadowSize = 1 if val == 0 else 0
	var shadowOffset = 4 if val == 0 else 0
	var textColor = Color.WHITE if val < 2 else Color.BLACK
	var outlineColor = Color.BLACK if val < 2 else Color.WHITE
	for label: Label in [
		$Content/Name,
		$Content/SmallName,
		$Content/TwoLineName,
		$Content/TypeBattle,
		$Content/TypeOther,
		$Content/Stats/HP,
		$Content/Stats/HP/Value,
		$Content/Stats/Attack,
		$Content/Stats/Attack/Value,
		$Content/Stats/AttackType,
		$Content/Field,
		$Content/Cost,
		$Content/Cost/Value,
	]:
		label.label_settings.outline_color = Color.BLACK
		label.label_settings.outline_size = textBorder1
	for label: Label in [
		$Content/Name,
		$Content/SmallName,
		$Content/TwoLineName,
		$Content/Stats/HP,
		$Content/Stats/HP/Value,
		$Content/Stats/Attack,
		$Content/Stats/Attack/Value,
		$Content/Stats/AttackType,
		$Content/Field,
		$Content/Cost,
		$Content/Cost/Value,
	]:
		pass
		#label.label_settings.shadow_size = shadowSize
		#label.label_settings.shadow_offset = Vector2(-shadowOffset, shadowOffset)
	$Content/SerialNumber.label_settings.outline_size = textBorder2
	$Content/Text.add_theme_constant_override("outline_size", textBorder1)
	if val < 2:
		$Content/Text.add_theme_color_override("default_color", Color.WHITE)
		$Content/Text.add_theme_color_override("font_outline_color", Color.BLACK)
	elif val == 2:
		$Content/Text.add_theme_color_override("default_color", Color.BLACK)
		$Content/Text.add_theme_color_override("font_outline_color", Color.WHITE)
	$Content/Text.clip_contents = false

func is_face_down() -> bool:
	return $Back.visible

func is_face_up() -> bool:
	return not $Back.visible

func turn_down():
	$Back.visible = true
	$Content.visible = false

func turn_up():
	$Back.visible = false
	$Content.visible = true

func flip():
	$Back.visible = !$Back.visible
	$Content.visible = !$Content.visible

func _on_property_hover_started(prop):
	$Tooltip.global_position.y = $Content/Cost.global_position.y - 5
	$Tooltip/Text.clear()
	$Tooltip/Text.append_text(Keyword.get_hint("prop:" + prop))
	$Tooltip.size.y = $Tooltip/Text.get_content_height() + 30
	$Tooltip.visible = true

func _on_property_hover_ended(prop):
	$Tooltip.visible = false

func _on_attack_type_mouse_entered() -> void:
	var attack_type: String = $Content/Stats/AttackType.text.to_lower()
	if len(attack_type) == 0:
		return
	$Tooltip.global_position.y = $Content/Stats/AttackType.global_position.y - 5
	$Tooltip/Text.clear()
	$Tooltip/Text.append_text(Keyword.get_hint("prop:" + attack_type))
	$Tooltip.size.y = $Tooltip/Text.get_content_height() + 30
	$Tooltip.visible = true

func _on_attack_type_mouse_exited() -> void:
	$Tooltip.visible = false

func _on_attribute_panel_mouse_entered() -> void:
	if attribute == Enum.Attribute.ANY:
		return
	$Tooltip.global_position.y = $Content/Attribute.global_position.y - 18
	$Tooltip/Text.clear()
	$Tooltip/Text.append_text(Keyword.get_hint("prop:" + Enum.get_attribute_name(attribute).to_lower()))
	$Tooltip.size.y = $Tooltip/Text.get_content_height() + 30
	$Tooltip.visible = true

func _on_attribute_panel_mouse_exited() -> void:
	$Tooltip.visible = false

func _on_text_meta_hover_started(meta):
	$Tooltip/Text.clear()
	$Tooltip/Text.append_text(Keyword.get_hint(meta))
	$Tooltip.global_position.y = $Content/Text.global_position.y - 5
	$Tooltip.size.y = $Tooltip/Text.get_content_height() + 30
	$Tooltip.visible = true

func _on_text_meta_hover_ended(meta):
	$Tooltip.visible = false

func _on_panel_mouse_entered():
	on_hover.emit()
	if !selectable:
		return
	is_hovering = true

func _on_panel_mouse_exited():
	is_hovering = false

func _on_panel_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if selectable and event.button_index == 1 or event.button_index == 2:
				selected.emit(event.button_index)
