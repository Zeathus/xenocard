extends CardEffect

class_name EffectModifyBattleDamageFrom

var amount: int = 0
var filter: CardFilter = null

func post_init():
	var params = param.split(",")
	amount = int(params[0])
	if len(params) >= 2:
		filter = CardFilter.new(params[1])

func take_damage(game_board: GameBoard, attacker: Card, damage: int, source: Card.DamageSource) -> int:
	if source != Card.DamageSource.BATTLE:
		return damage
	if filter and not filter.is_valid(card.owner, attacker):
		return damage
	damage += amount
	if damage < 0:
		damage = 0
	return damage
