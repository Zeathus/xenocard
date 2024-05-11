extends Effect

class_name EffectLevelUp

var filter: CardFilter

func post_init():
	filter = CardFilter.new(param)

func has_levelable_card() -> bool:
	if card.zone == Zone.HAND:
		for c in card.owner.field.get_battlefield_cards():
			if filter.is_valid(card.owner, c):
				return true
	return false

func skips_e_mark() -> bool:
	if has_levelable_card():
		return true
	return super.skips_e_mark()

func get_cost(cost: int) -> int:
	if has_levelable_card():
		return 0
	return super.get_cost(cost)

func ignore_unique(card: Card) -> bool:
	if card.zone == Zone.BATTLEFIELD and filter.is_valid(self.card.owner, card):
		return true
	return super.ignore_unique(card)

func is_valid_zone(new_zone: int, index: int, ret: bool) -> bool:
	if card.zone == Zone.HAND:
		for c in card.owner.field.get_battlefield_cards():
			if filter.is_valid(card.owner, c):
				return c.zone == new_zone and c.zone_index == index
	return ret

func can_replace_card(card: Card) -> bool:
	if filter.is_valid(self.card.owner, card):
		return true
	return false

func handle_occupied_zone(game_board: GameBoard, zone: int, index: int) -> bool:
	var occupying: Card = card.owner.field.get_card(zone, index)
	card.hp = card.max_hp - (occupying.max_hp - occupying.hp)
	return false
