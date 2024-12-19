class_name Random

static var rng: RandomNumberGenerator = RandomNumberGenerator.new()

static func set_seed(value: int):
	rng.set_seed(value)

static func shuffle(array: Array):
	if len(array) <= 1:
		return
	var copy: Array = array.duplicate()
	array.clear()
	while len(copy) > 0:
		var index: int = rng.randi_range(0, copy.size() - 1)
		array.push_back(copy[index])
		copy.remove_at(index)
