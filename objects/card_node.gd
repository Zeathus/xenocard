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
		z_index += 1
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
	$Card.set_e_mark(val)

func set_downed(val: bool):
	$Card.set_downed(val)

func set_in_motion(val: bool):
	in_motion = val

func set_help_text(text: String):
	$Card.set_help_text(text)

func hide_help_text():
	$Card.hide_help_text()

func is_hovering() -> bool:
	return $Card.is_hovering

func set_duration(duration: int):
	$Card.set_duration(duration)

func _on_card_selected(button_index: int) -> void:
	if button_index == 2:
		show_details.emit(self.card)
	else:
		selected.emit(self.card)

func _on_card_on_hover() -> void:
	on_hover.emit(self.card)
