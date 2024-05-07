extends Node2D

var done: bool = false
var handler = null
var answer: bool

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

func is_done():
	return done

func finish():
	if handler != null:
		handler.call(answer)

func _on_yes_button_pressed():
	answer = true
	done = true

func _on_no_button_pressed():
	answer = false
	done = true
