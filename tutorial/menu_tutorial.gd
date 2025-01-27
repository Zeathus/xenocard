extends Node2D

var row_scene = load("res://tutorial/tutorial_row.tscn")
var game_scene = load("res://scenes/game_board.tscn")

var selected_tutorial: Tutorial = null
var in_tutorial: bool = false

var tutorials: Array[Tutorial] = [
	Tutorial0Introduction.new(),
	Tutorial1HowToWin.new(),
	Tutorial2CreatingDecks.new(),
	Tutorial3StartOfTheGame.new(),
	Tutorial4CardTypes.new(),
	Tutorial5TheField.new(),
	Tutorial6CardPiles.new(),
	Tutorial7CardLayout.new(),
	Tutorial8PlayingCards.new(),
	Tutorial9CharacterCards.new(),
	Tutorial10Weapons.new(),
	Tutorial11Gnosis.new(),
	Tutorial12Phases.new(),
	Tutorial13AttackTypes.new(),
	Tutorial14TheBattlePhase.new(),
	Tutorial15Recap.new(),
]
var advanced_tutorial_start: int = len(tutorials)
var advanced_selected: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Info/ButtonStart.disabled = true
	load_tutorial_status()
	setup_tutorial_list()
	_on_tutorial_selected(tutorials[0])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if in_tutorial and visible:
		setup_tutorial_list()
		in_tutorial = false

func load_tutorial_status() -> void:
	var tutorial_data: Dictionary = Tutorial.get_tutorial_data()
	for tutorial in tutorials:
		if tutorial.get_id() in tutorial_data and tutorial_data[tutorial.get_id()]:
			tutorial.completed = true

func setup_tutorial_list():
	var container: VBoxContainer = $List/ScrollContainer/VBoxContainer
	while container.get_child_count() > 0:
		var child = container.get_child(0)
		child.disconnect("click_tutorial", _on_tutorial_selected)
		container.remove_child(child)
	var y_pos = 10
	for i in (range(advanced_tutorial_start, len(tutorials)) if advanced_selected else range(0, advanced_tutorial_start)):
		var tutorial: Tutorial = tutorials[i]
		var row: Node2D = row_scene.instantiate()
		row.set_tutorial(tutorial)
		if tutorial == selected_tutorial:
			row.set_pressed(true)
		row.position.x = 10
		row.position.y = y_pos
		row.connect("click_tutorial", _on_tutorial_selected)
		y_pos += 70
		container.add_child(row)
	container.custom_minimum_size.y = y_pos

func _on_tutorial_selected(tutorial: Tutorial) -> void:
	selected_tutorial = tutorial
	for child in $List/ScrollContainer/VBoxContainer.get_children():
		child.set_pressed(tutorial == child.tutorial)
	$Info/Title/Label.text = tutorial.get_name()
	$Info/Description.text = tutorial.get_description()
	$Info/ButtonStart.disabled = false
	$Info/Image.texture = tutorial.get_image()
	if tutorial.is_playable():
		$Info/ButtonMarkAsRead.visible = false
		$Info/ButtonMarkAsRead2.visible = true
		$Info/ButtonStart.visible = true
	else:
		$Info/ButtonMarkAsRead.visible = true
		$Info/ButtonMarkAsRead2.visible = false
		$Info/ButtonStart.visible = false

func _on_button_mark_as_read_pressed() -> void:
	if selected_tutorial:
		selected_tutorial.set_completed(true)
		setup_tutorial_list()

func _on_button_start_pressed():
	var game = game_scene.instantiate()
	selected_tutorial.set_game_options(game)
	get_parent().start_scene(game)
	in_tutorial = true

func _on_button_exit_pressed() -> void:
	get_parent().end_scene()

func _on_tab_basics_pressed() -> void:
	$List/TabBasics.button_pressed = true
	$List/TabAdvanced.button_pressed = false
	advanced_selected = false
	setup_tutorial_list()

func _on_tab_advanced_pressed() -> void:
	$List/TabBasics.button_pressed = false
	$List/TabAdvanced.button_pressed = true
	advanced_selected = true
	setup_tutorial_list()
