class_name Formula

static var count_regex
static var formula_regex

static func _static_init() -> void:
	count_regex = RegEx.new()
	count_regex.compile("count([a-z]*)\\(([^\\)]+)\\)")
	formula_regex = RegEx.new()
	formula_regex.compile("-?[0-9]+(([*+-/<>=]=?[0-9]+)+)?")

static func calc(formula: String, card: Card, game_board: GameBoard) -> int:
	var expr = count_regex.search(formula)
	while expr:
		var category = expr.get_string(1)
		var card_filter = CardFilter.new(expr.get_string(2))
		var count = 0
		var candidates = game_board.get_all_field_cards()
		if category == "junk":
			candidates = card.owner.junk.cards + card.owner.get_enemy().junk.cards
		for c in candidates:
			if card_filter.is_valid(card.owner, c):
				count += 1
		formula = formula.replace(expr.get_string(0), str(count))
		expr = count_regex.search(formula)
	while "junk" in formula:
		formula = formula.replace("junk", str(card.owner.junk.size()))
	while "lost" in formula:
		formula = formula.replace("lost", str(card.owner.lost.size()))
	while "deck" in formula:
		formula = formula.replace("deck", str(card.owner.deck.size()))
	while "hand" in formula:
		formula = formula.replace("hand", str(card.owner.hand.size()))
	while "maxhp" in formula:
		formula = formula.replace("maxhp", str(card.get_max_hp()))
	while "hp" in formula:
		formula = formula.replace("hp", str(card.hp))
	while "turncount" in formula:
		formula = formula.replace("turncount", str(card.turn_count))
	while "originalcost" in formula:
		formula = formula.replace("originalcost", str(card.get_original_cost()))
	while "cost" in formula:
		formula = formula.replace("cost", str(card.get_cost()))
	var validity = formula_regex.search(formula)
	if not validity or len(validity.get_string(0)) != len(formula):
		Logger.e("Invalid formula: " + formula)
		return 0
	var expression = Expression.new()
	expression.parse(formula)
	return expression.execute()

static func prepare(formula: String, card: Card, game_board: GameBoard):
	if formula[0] == "=":
		return str(Formula.calc(formula.substr(1), card, game_board))
	else:
		return formula
