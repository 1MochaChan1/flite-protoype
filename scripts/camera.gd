class_name Camera
extends Node3D

## This is the joystick input that's assigned to by the current scene
## if not explicitly overriden.
@export var v_joystick:VirtualJoystick
@export var follow_target:Node3D
@export var pitch_min:float = -50
@export var pitch_max:float = 50
@export var pitch_sensi = 0.1
@export var yaw_sensi = 0.1


@onready var spring_arm_3d = $CameraTarget/SpringArm3D
@onready var camera_target = $CameraTarget
@onready var camera_3d = $CameraTarget/SpringArm3D/Camera3D
@onready var reset_timer: Timer = $"ResetTimer"


var yaw:float
var pitch:float
var cam_target_basis:Basis
var is_moving:bool = false
var is_resetting:bool = false
var event:Vector2


# Called when the node enters the scene tree for the first time.
func _ready():
	camera_3d.position.z = spring_arm_3d.spring_length
	camera_target.global_position = follow_target.global_position


func _process(delta):
	if(OS.get_model_name() != "GenericDevice"):
		_handle_joystick_input()
	else:
		_handle_mouse_input()
	
	handle_cam(delta)


func handle_cam(delta):
	pitch = clamp(pitch, pitch_min, pitch_max)
	if(is_moving):
		if(not reset_timer.is_stopped()):
			reset_timer.stop()
		if(is_resetting):
			is_resetting = false
			
		spring_arm_3d.rotation_degrees.y = lerpf(
		spring_arm_3d.rotation_degrees.y, yaw, 10*delta)
		
		spring_arm_3d.rotation_degrees.x = lerpf(
			spring_arm_3d.rotation_degrees.x, pitch, 10*delta)
	
	if(not is_moving):
		if(reset_timer.is_stopped() and not is_resetting):
			reset_timer.start()
		
		if(is_resetting):
			spring_arm_3d.rotation_degrees = lerp(
				spring_arm_3d.rotation_degrees, Vector3.ZERO, 2.5*delta)
				
			#spring_arm_3d.rotation_degrees.y = lerpf(
				#spring_arm_3d.rotation_degrees.y, 0, 2.5*delta)
		#
			#spring_arm_3d.rotation_degrees.x = lerpf(
				#spring_arm_3d.rotation_degrees.x, 0, 2.5*delta)
	
	camera_target.global_position = follow_target.global_position
	
	cam_target_basis = lerp(
		camera_target.basis.orthonormalized(),
		follow_target.basis.orthonormalized(), delta * 5)
	camera_target.basis = cam_target_basis.orthonormalized()


func _handle_joystick_input():
	if(abs(v_joystick.output.x)!=0 or abs(v_joystick.output.y)!=0):
		is_moving = true
		yaw += -v_joystick.output.x * 10 * yaw_sensi
		pitch += v_joystick.output.y * 10 * pitch_sensi
	else:
		is_moving=false


func _handle_mouse_input():
	event = Input.get_last_mouse_velocity()
	if (event.length() > 0):
		is_moving = true
	else:
		is_moving = false

func _input(event):
	if(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		if ((event is InputEventMouseMotion) and \
		(OS.get_model_name() == "GenericDevice")):
			yaw += -event.relative.x * yaw_sensi
			pitch += event.relative.y * pitch_sensi


func _on_reset_timer_timeout() -> void:
	is_resetting = true
	pitch = 0
	yaw = 0
