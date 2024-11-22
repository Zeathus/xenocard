extends Node2D

var done: bool = false
var handler = null
var answer: bool
var timeout: float = -1
var timeout_answer: bool

func _process(delta: float) -> void:
	if timeout > 0:
		var old_timeout = timeout
		timeout = max(timeout - delta, 0)
		if ceil(old_timeout) != ceil(timeout):
			$Timer.text = "%d ◷" % [ceil(timeout)]
		if timeout <= 0:
			answer = timeout_answer
			done = true

func set_handler(val: Callable):
	handler = val

func set_message(val: String):
	$HeaderPanel/Label.text = val

func set_help(val: String):
	var text_size: int = 32
	while true:
		$HelpText.clear()
		$HelpText.push_font_size(text_size)
		$HelpText.append_text(val)
		if $HelpText.get_content_height() <= $HelpText.size.y:
			break
		text_size -= 2

func set_card(card: Card):
	if card == null:
		$CardDetails.visible = false
	else:
		position.x -= 128
		$CardDetails.visible = true
		$CardDetails/CardNode.turn_up()
		$CardDetails/CardNode.show_card(card.data)

func is_done():
	return done

func finish():
	if handler != null:
		handler.call(answer)

func set_timeout(time: float, default_answer: bool):
	timeout = time
	timeout_answer = default_answer
	$Timer.text = "%d ◷" % [ceil(timeout)]
	$Timer.visible = true

func set_yes_only():
	$YesButton.visible = false
	$NoButton.visible = false
	$OKButton.visible = true

func _on_yes_button_pressed():
	answer = true
	done = true

func _on_no_button_pressed():
	answer = false
	done = true
