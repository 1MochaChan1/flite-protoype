extends Sprite2D

@onready var parent = $".."

@export var max_length:float=100
@export var deadzone:=5.0


var is_pressing:bool=false
var angle:float
var distance_from_joystick:float

var x_diff:float
var y_diff:float



func _ready():
	max_length *= parent.scale.x


func _physics_process(delta):
	distance_from_joystick = (
		get_global_mouse_position().distance_to(parent.global_position))


	if(is_pressing):
		if(distance_from_joystick <= max_length):
			global_position = get_global_mouse_position()
		else:
			angle = parent.global_position.angle_to_point(get_global_mouse_position())
			global_position.x = parent.global_position.x + cos(angle) * max_length
			global_position.y = parent.global_position.y + sin(angle) * max_length
		calculate_vector()
	else:
		
		global_position = lerp(
			global_position, parent.global_position, delta * 50)
		parent.pos_vec = Vector2.ZERO
func calculate_vector():
	x_diff = global_position.x - parent.global_position.x
	y_diff = global_position.y - parent.global_position.y
	
	if abs(x_diff) >= parent.deadzone_multiplier_x * deadzone:
		parent.pos_vec.x = x_diff/max_length
	if abs(y_diff) >= parent.deadzone_multiplier_y * deadzone:
		parent.pos_vec.y = y_diff/max_length



func _on_button_button_down():
	#is_pressing = true
	pass


func _on_button_button_up():
	#is_pressing = false
	pass


func _on_touch_screen_button_pressed() -> void:
	is_pressing = true


func _on_touch_screen_button_released() -> void:
	is_pressing = false
