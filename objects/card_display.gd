extends Node2D

signal selected(button_index: int)
signal on_hover()

@export var selectable: bool = true
var original_scale: Vector2
var original_z: int
var is_hovering: bool = false
var old_is_hovering: bool = false

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
			$Overlay.scale = original_scale * 1.25
			$SelectBorder.scale = original_scale * 1.25
			$ValidBorder.scale = original_scale * 1.25
			$Back.scale = original_scale * 1.25
			$Content.rotation = -global_rotation
			$Overlay.rotation = -global_rotation
		else:
			$Content.scale = original_scale
			$Overlay.scale = original_scale
			$SelectBorder.scale = original_scale
			$ValidBorder.scale = original_scale
			$Back.scale = original_scale
			$Content.rotation = 0
			$Overlay.rotation = 0
	z_index = original_z
	if is_hovering:
		z_index += 1

func show_card(card: CardData):
	$Content/Background.texture = Enum.get_type_background(card.type)
	$Content/Name.text = ""
	$Content/SmallName.text = ""
	$Content/TwoLineName.text = ""
	var name = card.name
	if "\n" in name:
		$Content/TwoLineName.text = name
	elif len(name) <= 20:
		$Content/Name.text = name
	else:
		$Content/SmallName.text = name
	$Content/TypeBattle.visible = (card.type == Enum.Type.BATTLE)
	$Content/TypeOther.visible = (card.type != Enum.Type.BATTLE)
	$Content/Attribute.visible = (card.type == Enum.Type.BATTLE)
	$Content/Stats.visible = (card.type == Enum.Type.BATTLE)
	var expanded_text: String = Keyword.expand_keywords(card.text)
	var text_size: int = 36
	while true:
		$Content/Text.clear()
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
		$Content/Attribute.set_attribute(card.attribute)
		$Content/Stats/HP/Value.text = "%d" % card.max_hp
		$Content/Stats/Attack/Value.text = "%d" % card.atk
		$Content/Stats/AttackType.text = Enum.get_attack_type_name(card.attack_type)
	else:
		$Content/TypeOther.text = Enum.get_type_name(card.type)
	$Content/Picture.texture = card.get_image()

func is_face_down() -> bool:
	return $Back.visible

func is_face_up() -> bool:
	return not $Back.visible

func turn_down():
	$Back.visible = true

func turn_up():
	$Back.visible = false

func flip():
	$Back.visible = !$Back.visible

func set_e_mark(val: bool):
	$Overlay/EMark.visible = val

func set_downed(val: bool):
	$Overlay/Downed.visible = val

func set_duration(val: int):
	if val <= 0:
		$Duration.visible = false
	else:
		$Duration.visible = true
		$Duration/Value.text = "%d" % val

func _on_text_meta_hover_started(meta):
	$Tooltip/Text.clear()
	$Tooltip/Text.append_text(Keyword.get_hint(meta))
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
