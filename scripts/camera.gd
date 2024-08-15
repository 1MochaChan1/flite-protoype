extends Node3D

@export var follow_target:Node3D
@export var pitch_min:float = -50
@export var pitch_max:float = 50
@export var pitch_sensi = 0.002
@export var yaw_sensi = 0.002
@export var v_joystick:VirtualJoystick


@onready var spring_arm_3d = $CameraTarget/SpringArm3D
@onready var camera_target = $CameraTarget
@onready var camera_3d = $CameraTarget/SpringArm3D/Camera3D
@onready var reset_timer: Timer = $"ResetTimer"


var yaw:float
var pitch:float
var cam_target_basis:Basis
var moving:bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	camera_3d.position.z = spring_arm_3d.spring_length
	camera_target.global_position = follow_target.global_position


func _physics_process(delta):
	if(v_joystick):
		_handle_joystick_input()
	handle_cam(delta)

func handle_cam(delta):
	pitch = clamp(pitch, pitch_min, pitch_max)

	if(moving):
		spring_arm_3d.rotation_degrees.y = lerpf(
		spring_arm_3d.rotation_degrees.y, yaw, 10*delta)
		
		spring_arm_3d.rotation_degrees.x = lerpf(
			spring_arm_3d.rotation_degrees.x, pitch, 10*delta)
	

	
	if(not moving):
		spring_arm_3d.rotation_degrees.y = lerpf(
		spring_arm_3d.rotation_degrees.y, 0, delta * 0.1)
		
		spring_arm_3d.rotation_degrees.x = lerpf(
		spring_arm_3d.rotation_degrees.x, 0, delta * 0.1)
	
	print(moving)
	print(spring_arm_3d.rotation_degrees)
	
	
	camera_target.global_position = follow_target.global_position
	cam_target_basis = lerp(
		camera_target.basis.orthonormalized(),
		follow_target.basis.orthonormalized(), delta * 5)
	camera_target.basis = cam_target_basis.orthonormalized()

func _handle_joystick_input():
	if(abs(v_joystick.output.x)!=0 or abs(v_joystick.output.y)!=0):
		moving = true
		yaw += -v_joystick.output.x * 10 * yaw_sensi
		pitch += v_joystick.output.y * 10 * pitch_sensi
	else:
		moving = false

func _input(event):
	if(not v_joystick):
		if ((event is InputEventMouseMotion) and \
		(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED)):
			moving = true
			yaw += -event.relative.x * yaw_sensi
			pitch += event.relative.y * pitch_sensi 
		else:
			moving = false
	#elif(v_joystick):
		#if(v_joystick.output.length() > 0):
			#yaw += v_joystick.output.x * 10 * yaw_sensi
			#pitch += v_joystick.output.y * 10 * pitch_sensi
	

	
