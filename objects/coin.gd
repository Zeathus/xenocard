extends Node2D

class_name Coin

func flip_heads() -> void:
	$Panel/Label.text = "You go first!"
	$AnimationPlayer.play("flip_heads")

func flip_tails() -> void:
	$Panel/Label.text = "You go second"
	$AnimationPlayer.play("flip_tails")

func show_result() -> void:
	$AnimationPlayer.play("show_result")

func reset() -> void:
	$AnimationPlayer.play("RESET")

func animating() -> bool:
	return $AnimationPlayer.is_playing()
