extends CustomScene


func _on_play_pressed() -> void:
	go_to_level_select()
	pass


func _on_quit_pressed() -> void:
	get_tree().quit()
