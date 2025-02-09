extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Options/VolumeMusic.value = Options.music_volume
	$Options/VolumeSounds.value = Options.sounds_volume
	$Options/VolumeMusic/Mute.button_pressed = Options.music_mute
	$Options/VolumeSounds/Mute.button_pressed = Options.sounds_mute
	$Options/RotateEnemyCards.button_pressed = Options.rotate_enemy_cards
	$Options/AlwaysShowATKBoosts.button_pressed = Options.always_show_atk_boosts

func _on_button_exit_pressed() -> void:
	Options.save()
	get_parent().end_scene()

func _on_lang_us_pressed() -> void:
	Options.set_locale("en")

func _on_lang_jp_pressed() -> void:
	Options.set_locale("jp")

func _on_volume_music_value_changed(value: float) -> void:
	$Options/VolumeMusic/Value.text = "%d%%" % value
	Options.set_music_volume(value)

func _on_volume_sounds_value_changed(value: float) -> void:
	$Options/VolumeSounds/Value.text = "%d%%" % value
	Options.set_sounds_volume(value)

func _on_volume_sounds_drag_ended(value_changed: bool) -> void:
	$Options/VolumeSounds/AudioStream.play()

func _on_music_mute_toggled(toggled_on: bool) -> void:
	Options.set_music_mute(toggled_on)

func _on_sounds_mute_toggled(toggled_on: bool) -> void:
	Options.set_sounds_mute(toggled_on)

func _on_rotate_enemy_cards_toggled(toggled_on: bool) -> void:
	Options.rotate_enemy_cards = toggled_on

func _on_always_show_atk_boosts_toggled(toggled_on: bool) -> void:
	Options.always_show_atk_boosts = toggled_on
