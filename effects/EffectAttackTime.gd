extends Effect

class_name EffectAttackTime

var value: int = 1

func post_init():
	value = int(param)

func is_active() -> bool:
	return true

func get_atk_time(time: int) -> int:
	return value
