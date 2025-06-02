extends Node2D

class_name Coin

func flip_heads() -> void:
	$AnimationPlayer.play("flip_heads")

func flip_tails() -> void:
	$AnimationPlayer.play("flip_tails")

func animating() -> bool:
	return $AnimationPlayer.is_playing()
