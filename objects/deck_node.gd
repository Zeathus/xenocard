extends Node2D

signal selected(card: Card)
signal show_details(card: Card)
signal on_hover(card: Card)

var original_z: int
var in_motion: bool = false
var card: Card
var disable_in_motion_after_animation: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	original_z = z_index

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	z_index = original_z
	if in_motion:
		z_index += 30
	if disable_in_motion_after_animation and not animating():
		in_motion = false
		disable_in_motion_after_animation = false

func load_card(card: Card):
	self.card = card
	$Pivot/Card.show_card(card.data)

func is_face_down() -> bool:
	return $Pivot/Card.is_face_down()

func is_face_up() -> bool:
	return $Pivot/Card.is_face_up()

func turn_down():
	$Pivot/Card.turn_down()

func turn_up():
	$Pivot/Card.turn_up()

func flip():
	$Pivot/Card.flip()

func set_e_mark(val: bool):
	$Pivot/Overlay/EMark.visible = val

func set_downed(val: bool):
	$Pivot/Overlay/Downed.visible = val

func set_duration(val: int):
	if val <= 0:
		$Pivot/Overlay/Duration.visible = false
	else:
		$Pivot/Overlay/Duration.visible = true
		$Pivot/Overlay/Duration.text = "%d ◷" % val

func set_help_text(text: String):
	$Pivot/HelpText.visible = true
	$Pivot/HelpText.text = text

func set_in_motion(val: bool):
	in_motion = val

func hide_help_text():
	$Pivot/HelpText.visible = false

func is_hovering() -> bool:
	return $Pivot/Card.is_hovering

func play_animation(anim: String, speed_scale: float = 1.0):
	$AnimationPlayer.speed_scale = speed_scale
	$AnimationPlayer.play(anim)

func animating() -> bool:
	return $AnimationPlayer.is_playing()

func _on_card_selected(button_index: int) -> void:
	if button_index == 2:
		show_details.emit(self.card)
	else:
		selected.emit(self.card)

func _on_card_on_hover() -> void:
	on_hover.emit(self.card)
