class_name CusMenuButton extends Button

@onready var sfx_click: AudioStreamPlayer = $Click

## This is called after the buttons is pressed and some custom functions
## are executed
signal custom_pressed

func _ready() -> void:
	sfx_click.finished.connect(func():custom_pressed.emit())

func _on_pressed() -> void:
	sfx_click.play()
	pass
