class_name HUD extends CanvasLayer

@onready var look_stick:Control=$ControlHud/Lookstick
@onready var move_stick:Control=$ControlHud/Movestick
@onready var lbl_timer: Label = $"Control/Top Hud/Timer/TimerLabel"
@onready var lbl_message: Label = $"Control/Top Hud/Message/MessageLabel"
@onready var pause_btn:TextureButton = $"Control/Top Hud/Pause/TextureButton"

@export var txt_timer:String:
	set(value):
		lbl_timer.text=value
	get: return lbl_timer.text

@export var txt_message:String:
	set(value):
		lbl_message.text=value
	get: return lbl_message.text
		
