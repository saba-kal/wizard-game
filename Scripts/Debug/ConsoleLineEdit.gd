extends LineEdit


func _on_focus_entered():
	text = ""


func _on_focus_exited():
	text = ""


func _on_gui_input(event:InputEvent):
	if event.is_action_pressed("console"):
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("consoleuphistory"):
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("consoledownhistory"):
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("consoleautocomplete"):
		get_viewport().set_input_as_handled()