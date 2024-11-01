extends Effect

class_name EffectModifyDamageFrom

var amount: int = 0
var filter: CardFilter = null

func post_init():
	var params = param.split(",")
	amount = int(params[0])
	if len(params) >= 2:
		filter = CardFilter.new(params[1])

func take_damage(game_board: GameBoard, attacker: Card, damage: int, source: Damage) -> int:
	if filter and not filter.is_valid(parent.host.owner, attacker):
		return damage
	damage += amount
	if damage < 0:
		damage = 0
	return damage
