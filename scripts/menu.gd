extends CustomScene

func _on_button_pressed() -> void:
	#call_scene_change.emit('res://scenes/level_select.tscn')
	get_tree().change_scene_to_packed(
		preload('res://scenes/level_select.tscn'))
