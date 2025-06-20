extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Options/VolumeMusic.value = Options.music_volume
	$Options/VolumeSounds.value = Options.sounds_volume
	$Options/VolumeUI.value = Options.ui_volume
	$Options/VolumeMusic/Mute.set_pressed_no_signal(Options.music_mute)
	$Options/VolumeSounds/Mute.set_pressed_no_signal(Options.sounds_mute)
	$Options/VolumeUI/Mute.set_pressed_no_signal(Options.ui_mute)
	$Options/RotateEnemyCards.set_pressed_no_signal(Options.rotate_enemy_cards)
	$Options/AlwaysShowATKBoosts.set_pressed_no_signal(Options.always_show_atk_boosts)
	$Options/DisableBlockReminder.set_pressed_no_signal(Options.disable_block_reminder)
	$Options/Username.text = Options.username

func _on_button_exit_pressed() -> void:
	get_parent().play_se("click3")
	Options.save()
	get_parent().end_scene()

func _on_lang_us_pressed() -> void:
	get_parent().play_se("click1")
	Options.set_locale("en")

func _on_lang_jp_pressed() -> void:
	get_parent().play_se("click1")
	Options.set_locale("jp")

func _on_volume_music_value_changed(value: float) -> void:
	$Options/VolumeMusic/Value.text = "%d%%" % value
	Options.set_music_volume(value)

func _on_volume_sounds_value_changed(value: float) -> void:
	$Options/VolumeSounds/Value.text = "%d%%" % value
	Options.set_sounds_volume(value)

func _on_volume_sounds_drag_ended(value_changed: bool) -> void:
	$Options/VolumeSounds/AudioStream.play()

func _on_volume_ui_value_changed(value: float) -> void:
	$Options/VolumeUI/Value.text = "%d%%" % value
	Options.set_ui_volume(value)

func _on_volume_ui_drag_ended(value_changed: bool) -> void:
	$Options/VolumeUI/AudioStream.play()

func _on_music_mute_toggled(toggled_on: bool) -> void:
	get_parent().play_se("switch6" if toggled_on else "switch8")
	Options.set_music_mute(toggled_on)

func _on_sounds_mute_toggled(toggled_on: bool) -> void:
	get_parent().play_se("switch6" if toggled_on else "switch8")
	Options.set_sounds_mute(toggled_on)

func _on_ui_mute_toggled(toggled_on: bool) -> void:
	get_parent().play_se("switch6" if toggled_on else "switch8")
	Options.set_ui_mute(toggled_on)

func _on_rotate_enemy_cards_toggled(toggled_on: bool) -> void:
	get_parent().play_se("switch6" if toggled_on else "switch8")
	Options.rotate_enemy_cards = toggled_on

func _on_always_show_atk_boosts_toggled(toggled_on: bool) -> void:
	get_parent().play_se("switch6" if toggled_on else "switch8")
	Options.always_show_atk_boosts = toggled_on

func _on_disable_block_reminder_toggled(toggled_on: bool) -> void:
	get_parent().play_se("switch6" if toggled_on else "switch8")
	Options.disable_block_reminder = toggled_on

func _on_username_text_changed() -> void:
	var base_username: String = $Options/Username.text
	var regex: RegEx = RegEx.new()
	regex.compile("[^A-Z^a-z^0-9^_]")
	var username: String = regex.sub(base_username, "", true)
	if len(username) > 15 or base_username != username:
		username = username.substr(0, min(len(username), 15))
		var old_column: int = $Options/Username.get_caret_column()
		$Options/Username.text = username
		$Options/Username.set_caret_column(min(len(username), 15, old_column))
	Options.username = username
