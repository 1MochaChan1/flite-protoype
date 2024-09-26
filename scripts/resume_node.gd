extends Node

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if(get_tree().paused):
			get_tree().paused = false
			get_parent().visible = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
