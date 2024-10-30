extends Effect

class_name EffectIgnoreCost

func is_active() -> bool:
	return target.zone == Enum.Zone.HAND

func get_cost(cost: int) -> int:
	return 0
