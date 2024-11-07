extends Node2D

signal selected(card: Card)
signal show_details(card: Card)
signal on_hover(card: Card)

var original_z: int
var in_motion: bool = false
var card: Card

# Called when the node enters the scene tree for the first time.
func _ready():
	original_z = z_index

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	z_index = original_z
	if $Card.is_hovering:
		$Overlay.rotation = -global_rotation
		z_index += 1
	else:
		$Overlay.rotation = 0
	$Overlay.scale = $Card/Content.scale
	$SelectBorder.scale = $Card/Content.scale
	$ValidBorder.scale = $Card/Content.scale
	if card:
		if card.zone == Enum.Zone.HAND:
			z_index += 20
		elif card.get_type() == Enum.Type.BATTLE and card.get_attribute() == Enum.Attribute.WEAPON and card.equipped_by:
			z_index += 2
	if in_motion:
		z_index += 30

func load_card(card: Card):
	self.card = card
	$Card.show_card(card.data)

func is_face_down() -> bool:
	return $Card.is_face_down()

func is_face_up() -> bool:
	return $Card.is_face_up()

func turn_down():
	$Card.turn_down()

func turn_up():
	$Card.turn_up()

func flip():
	$Card.flip()

func set_e_mark(val: bool):
	$Overlay/EMark.visible = val

func set_downed(val: bool):
	$Overlay/Downed.visible = val

func set_duration(val: int):
	if val <= 0:
		$Overlay/Duration.visible = false
	else:
		$Overlay/Duration.visible = true
		$Overlay/Duration.text = "%d ◷" % val

func set_help_text(text: String):
	$HelpText.visible = true
	$HelpText.text = text

func set_in_motion(val: bool):
	in_motion = val

func hide_help_text():
	$HelpText.visible = false

func is_hovering() -> bool:
	return $Card.is_hovering

func _on_card_selected(button_index: int) -> void:
	if button_index == 2:
		show_details.emit(self.card)
	else:
		selected.emit(self.card)

func _on_card_on_hover() -> void:
	on_hover.emit(self.card)
