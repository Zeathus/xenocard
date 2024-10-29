class_name Formula

static var count_regex
static var formula_regex

static func _static_init() -> void:
	count_regex = RegEx.new()
	count_regex.compile("count\\(([^\\)]+)\\)")
	formula_regex = RegEx.new()
	formula_regex.compile("[0-9]+(([*+-/][0-9]+)+)?")

static func calc(formula: String, card: Card, game_board: GameBoard) -> int:
	var values = {
		"junk": card.owner.junk.size(),
		"lost": card.owner.lost.size(),
		"deck": card.owner.deck.size()
	}
	for key in values:
		formula = formula.replace(key, str(values[key]))
	var expr = count_regex.search(formula)
	while expr:
		var card_filter = CardFilter.new(expr.get_string(1))
		var count = 0
		for c in game_board.get_all_field_cards():
			if card_filter.is_valid(card.owner, c):
				count += 1
		formula = formula.replace(expr.get_string(0), str(count))
		expr = count_regex.search(formula)
	var validity = formula_regex.search(formula)
	if not validity or len(validity.get_string(0)) != len(formula):
		print("Invalid formula: ", formula)
		return 0
	var expression = Expression.new()
	expression.parse(formula)
	return expression.execute()

static func prepare(formula: String, card: Card, game_board: GameBoard):
	if formula[0] == "=":
		return str(Formula.calc(formula.substr(1), card, game_board))
	else:
		return formula
