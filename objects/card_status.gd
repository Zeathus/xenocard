extends Node2D

func show_card(card: Card):
	if not card:
		self.visible = false
		return
	self.visible = true
	$Panel/ValueHP.text = "%d/%d" % [card.hp, card.get_max_hp()]
	var original_atk = card.get_original_atk()
	if card.equipped_weapon and card.equipped_weapon.get_original_atk() != 0:
		original_atk = card.equipped_weapon.get_original_atk()
	var atk = card.get_atk({"ignore_phase": Options.always_show_atk_boosts})
	$Panel/ValueATK.text = "%d" % atk
	if atk != original_atk:
		$Panel/ATKArrow.visible = true
		$Panel/ATKArrow.position.x = $Panel/ValueATK.get_character_bounds(0).position.x + 8
		if atk > original_atk:
			$Panel/ATKArrow.rotation = 0
		elif atk < original_atk:
			$Panel/ATKArrow.rotation = PI
	else:
		$Panel/ATKArrow.visible = false
	$Panel/AttackType.text = Enum.get_attack_type_name(card.get_attack_type())
	$Panel/Attribute.set_attribute(card.get_attribute())
	refresh_bar($Panel/PanelHP/Gauge, card.hp, card.get_max_hp())
	refresh_bar($Panel/PanelCharge/Gauge, card.atk_timer, card.get_atk_time())

func _ready():
	self.rotation = -global_rotation

func refresh_bar(panel, value: int, max_value: int):
	panel.value = value
	panel.max_value = max_value
	panel.queue_redraw()
