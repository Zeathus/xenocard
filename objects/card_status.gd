extends Node2D

func show_card(card: Card):
	if not card:
		self.visible = false
		return
	self.visible = true
	$Panel/ValueHP.text = "%d/%d" % [card.hp, card.get_max_hp()]
	var original_atk = card.get_original_atk()
	var atk = card.get_atk()
	if atk > original_atk:
		$Panel/ValueATK.text = "⮝%d" % atk
	elif atk < original_atk:
		$Panel/ValueATK.text = "⮟%d" % atk
	else:
		$Panel/ValueATK.text = "%d" % atk
	$Panel/AttackType.text = Enum.get_attack_type_name(card.get_attack_type())
	$Panel/Attribute.set_attribute(card.get_attribute())
	refresh_bar($Panel/PanelHP, card.hp, card.get_max_hp())
	refresh_bar($Panel/PanelCharge, card.atk_timer, card.get_atk_time())

func _ready():
	self.rotation = -global_rotation

func refresh_bar(panel, value: int, max_value: int):
	for i in panel.get_children():
		i.visible = false
	var start_x = 4
	var total_width: float = 124.0
	var total_spacing: float = (max_value - 1) * 4
	var width: float = (total_width - total_spacing) / max_value
	for i in range(max_value):
		var bar = panel.find_child(("On%d" if value >= i + 1 else "Off%d") % (i + 1))
		bar.visible = true
		bar.position.x = start_x + (width + 4) * i
		bar.size.x = width
