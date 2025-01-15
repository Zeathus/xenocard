extends Event

class_name EventSpecialAttack

var player: Player
var attacker: Card
var damage: int
var filter: CardFilter
var targets: Array
var attack_done: bool = false

func _init(_game_board: GameBoard, _attacker: Card, _damage: int, _filter: CardFilter):
	super(_game_board)
	attacker = _attacker
	damage = _damage
	filter = _filter

func get_name() -> String:
	return "SpecialAttack"

func on_start():
	broadcast()
	var anim_targets: Array[Node2D] = []
	for card in game_board.get_all_field_cards():
		if filter.is_valid(attacker.owner, card):
			targets.push_back(card)
			anim_targets.push_back(card.instance)
	if len(targets) == 0:
		finish()
		return
	var anim: AnimationAttack = AnimationAttack.new(attacker.instance, anim_targets, damage, Enum.AttackType.NONE)
	queue_event(EventAnimation.new(game_board, anim))

func on_finish():
	game_board.refresh()

func process(delta):
	sort_children()
	if pass_to_child("process", [delta]):
		return
	if not attack_done:
		attack_done = true
		attack()
	else:
		finish()

func attack():
	if len(targets) == 0:
		return
	for t in targets:
		var damage_event: EventDamage = EventDamage.new(game_board, attacker, t, damage, Damage.new(Damage.BATTLE))
		adopt_children(damage_event)
		queue_event(damage_event)
	sort_children()

func broadcast():
	if game_board.is_server():
		for p: Player in [game_board.get_turn_player(), game_board.get_turn_enemy()]:
			var args: Array = [attacker.get_online_id(p.id == 1), str(damage), filter.string]
			p.controller.broadcast_event(get_name(), args)
