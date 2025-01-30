extends Node2D

class_name GameHand

var cards: Array[Card]
var game_board: GameBoard
var hovered_card: Card
var max_width: int = 700

func _ready():
	cards = []

func _process(delta):
	var mouse_pos: Vector2 = get_global_mouse_position()
	for i in range(size()):
		var card: Card = cards[i]
		var target_pos: Vector2 = get_target_pos(i, card, mouse_pos)
		if card.instance.in_motion:
			continue
		var speed: int = 1000 * delta
		if card.instance.position.x != target_pos.x or card.instance.position.y != target_pos.y:
			var distance: Vector2 = (target_pos - card.instance.position).normalized()
			if distance.x < 0:
				card.instance.position.x = max(card.instance.position.x + distance.x * speed, target_pos.x)
			elif distance.x > 0:
				card.instance.position.x = min(card.instance.position.x + distance.x * speed, target_pos.x)
			if distance.y < 0:
				card.instance.position.y = max(card.instance.position.y + distance.y * speed, target_pos.y)
			elif distance.y > 0:
				card.instance.position.y = min(card.instance.position.y + distance.y * speed, target_pos.y)
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

func get_target_pos(index: int, card: Card, mouse_pos: Vector2) -> Vector2:
	var min_x: int = -max_width / 2
	var step_x: float = max_width / (size() + 1)
	var target_x: float = min_x + (index + 1) * step_x
	var target_y: float = 0
	if card.is_selected():
		target_y = -64
	else:
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
			target_y = -64 * (128 - distance) / 128
		else:
			target_y = 0
	return Vector2(target_x, target_y)

func refresh():
	return
	if size() == 0:
		return
	var min_x: int = -max_width / 2
	var step_x: float = max_width / (size() + 1)
	#var min_angle: float = -PI / 8
	#var step_angle: float = (PI / 4) / (size() + 1)
	for i in range(self.size()):
		var card: Card = cards[i]
		card.instance.position.x = min_x + (i + 1) * step_x
		#card.instance.rotation = min_angle + (i + 1) * step_angle

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
