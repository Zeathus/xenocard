extends Node2D

signal selected(card: Card)
signal show_details(card: Card)
signal on_hover(card: Card)

@export var selectable: bool = true
var original_scale: Vector2
var original_z: int
var is_hovering: bool = false
var old_is_hovering: bool = false
var in_motion: bool = false
var card: Card

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
	if card:
		if card.zone == Card.Zone.HAND:
			z_index += 20
		elif card.type == Card.Type.BATTLE and card.attribute == Card.Attribute.WEAPON and card.equipped_by:
			z_index += 2
	if in_motion:
		z_index += 30

func load_card(card: Card):
	self.card = card
	self.refresh()

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

func refresh():
	$Content/Background.texture = Card.get_type_background(card.type)
	$Content/Name.text = ""
	$Content/SmallName.text = ""
	$Content/TwoLineName.text = ""
	if "\n" in card.name:
		$Content/TwoLineName.text = card.name
	elif len(card.name) <= 20:
		$Content/Name.text = card.name
	else:
		$Content/SmallName.text = card.name
	$Content/TypeBattle.visible = card.has_stats()
	$Content/TypeOther.visible = !card.has_stats()
	$Content/Attribute.visible = card.has_stats()
	$Content/Stats.visible = card.has_stats()
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
	$Content/Rarity.texture = Card.get_rarity_icon(card.rarity)
	var field_icons: Array[Node2D] = [
		$Content/Field/Value1, $Content/Field/Value2,
		$Content/Field/Value3, $Content/Field/Value4
	]
	for i in range(len(field_icons)):
		if len(card.field) > i:
			field_icons[i].visible = true
			field_icons[i].set_attribute(card.field[i])
		else:
			field_icons[i].visible = false
	if card.has_stats():
		$Content/Attribute.set_attribute(card.attribute)
		$Content/Stats/HP/Value.text = "%d" % card.max_hp
		$Content/Stats/Attack/Value.text = "%d" % card.atk
		$Content/Stats/AttackType.text = Card.get_target_name(card.target)
	else:
		$Content/TypeOther.text = Card.get_type_name(card.type)
	var image_file: String = "res://sprites/card_images/%s/%s.png" % [card.set_name, card.id]
	if ResourceLoader.exists(image_file):
		$Content/Picture.texture = load(image_file)
	else:
		$Content/Picture.texture = load("res://sprites/card_images/missing_artwork.png")
		push_error("Failed to find card image '%s'" % image_file)

func set_in_motion(val: bool):
	in_motion = val

#func _on_hitbox_input_event(viewport, event, shape_idx):
#	if event is InputEventMouseButton:
#		if event.pressed:
#			if event.button_index == 1:
#				if selectable:
#					selected.emit(self.card)
#			elif event.button_index == 2:
#				if self.is_face_up():
#					show_details.emit(self)

func _on_text_meta_hover_started(meta):
	$Tooltip/Text.clear()
	$Tooltip/Text.append_text(Keyword.get_hint(meta))
	$Tooltip.size.y = $Tooltip/Text.get_content_height() + 30
	$Tooltip.visible = true

func _on_text_meta_hover_ended(meta):
	$Tooltip.visible = false

func _on_panel_mouse_entered():
	on_hover.emit(self.card)
	if !selectable:
		return
	is_hovering = true

func _on_panel_mouse_exited():
	is_hovering = false

func _on_panel_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == 1:
				if selectable:
					selected.emit(self.card)
			elif event.button_index == 2:
				if self.is_face_up():
					show_details.emit(self.card)
