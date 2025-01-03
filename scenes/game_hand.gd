extends Node2D

class_name GameHand

var cards: Array[Card]
var game_board: GameBoard
var hovered_card: Card

func _ready():
	cards = []

func _process(delta):
	var mouse_pos: Vector2 = get_global_mouse_position()
	for card in cards:
		if card.instance.in_motion:
			continue
		if card.instance.is_face_down():
			continue
		if card.is_selected():
			card.instance.position.y = -64
			continue
		var pos: Vector2 = card.instance.global_position
		var left = (pos.x - 64)
		var right = (pos.x + 64)
		var dist: Vector2 = Vector2(0, 0)
		if mouse_pos.x >= left and mouse_pos.x <= right:
			dist.x = 0
		else:
			dist.x = min(abs(mouse_pos.x - left), abs(mouse_pos.x - right)) / 2
		if card.instance.global_rotation == 0:
			dist.y = max((pos.y - 32) - mouse_pos.y, 0)
		else:
			dist.y = max(mouse_pos.y - (pos.y + 32), 0)
		var distance: float = dist.length()
		if distance < 128:
			card.instance.position.y = -64 * (128 - distance) / 128
		else:
			card.instance.position.y = 0
	if hovered_card:
		if hovered_card.is_hovered() and hovered_card in cards:
			if global_rotation == 0:
				$FieldRequirementPreview.global_position = hovered_card.instance.global_position - Vector2(0, 140)
				$FieldRequirementPreview.rotation = 0
			else:
				$FieldRequirementPreview.global_position = hovered_card.instance.global_position + Vector2(0, 140)
				$FieldRequirementPreview.rotation = -global_rotation
		else:
			hide_field_requirements()
			hovered_card = null

func add_card(card: Card):
	card.reset()
	card.zone = Enum.Zone.HAND
	cards.push_back(card)
	add_child(card.instance)
	card.instance.selected.connect(_on_card_selected)
	card.instance.on_hover.connect(_on_card_hovered)
	self.refresh()

func remove(card: Card):
	card.instance.selected.disconnect(_on_card_selected)
	card.instance.on_hover.disconnect(_on_card_hovered)
	remove_child(card.instance)
	cards.erase(card)
	self.refresh()

func size():
	return len(cards)

func refresh():
	var max_x = min(self.size(), 4) * 64 - 64
	for i in range(self.size()):
		var card: Card = cards[self.size() - i - 1]
		card.instance.position.x = max_x - i * 128

func get_new_card_position() -> Vector2:
	if global_rotation == 0:
		return global_position + Vector2(min(self.size(), 4) * 64 - 64, 0)
	else:
		return global_position - Vector2(min(self.size(), 4) * 64 - 64, 0)

func show_field_requirements():
	$FieldRequirementPreview.set_requirement_and_resources(
		hovered_card.get_field_requirements(),
		hovered_card.owner.get_resources()
	)
	$FieldRequirementPreview.visible = true

func hide_field_requirements():
	$FieldRequirementPreview.visible = false

func _on_card_hovered(card: Card):
	if not card.instance or card.instance.is_face_down():
		return
	hovered_card = card
	show_field_requirements()

func _on_card_selected(card: Card):
	game_board.on_hand_card_selected(self, card)
