extends CharacterBody3D
const GRAVITY = 10

var pitch_input = 0
var yaw_input = 0

var base_speed = 30
var target_speed = 0

var current_speed:float = 0
var charged_speed:float = 0

var rotate_speed:float = 0

# delta
@export var pitch_rotate_delta:float = 1
@export var yaw_rotate_delta:float = 2.0
@export var dive_throttle_delta:float=1
@export var current_speed_delta:float=1
@export var back_to_normal_speed_delta = 0.001
@export var max_pitch_angle:float = 75

@onready var vel_label = $"../CanvasLayer/Control/Velocity"
@onready var mesh_container = $MeshContainer

var rot = 0
var pitch_cal = 0

var pitch_quat:Quaternion
var yaw_quat:Quaternion

var _tween:Tween

func _ready():
	current_speed = base_speed

func _physics_process(delta):
	vel_label.text = str(velocity)

	_handle_input(delta)
	
	orientation_adjustment(delta)
	handle_physics(delta)

############### Custom Functions ###############

func _handle_input(delta):
	yaw_input = Input.get_axis("ui_right", "ui_left")
	pitch_input = Input.get_axis("ui_down", "ui_up")


func handle_physics(delta):

	
	charged_speed = clamp(charged_speed, 0,3)
	current_speed = lerpf(
		current_speed, ((target_speed * charged_speed) + base_speed), delta)
# CAUTION: Adding the velocity
	velocity = transform.basis.z * current_speed
	velocity.y = lerpf(
		velocity.y, (-GRAVITY * 10) * (pitch_input + 1), delta)
	
	move_and_slide() 


func orientation_adjustment(delta):
	# NOTE: Calculating `target_speed`
	
	if(pitch_input>0):
		pitch_quat = Quaternion(
			Vector3.RIGHT, deg_to_rad(pitch_input*max_pitch_angle))
		
		target_speed = lerpf(
			target_speed, 60+base_speed, dive_throttle_delta * delta )
		charged_speed += 0.1
	
	elif(pitch_input < 0.0):
		pitch_quat = Quaternion(
			Vector3.RIGHT,  deg_to_rad(pitch_input*max_pitch_angle))
		
		target_speed = lerpf(target_speed, -GRAVITY, delta)
		charged_speed -= 0.1
		
		
	else:
		pitch_quat = Quaternion(Vector3.RIGHT, 0)
		target_speed = lerpf(target_speed, 0, back_to_normal_speed_delta)
	
	# TODO: Tween this motion, don't slerp
	if(yaw_input!=0):
		rot += 2.5 * yaw_input
	
	yaw_quat = Quaternion(Vector3.UP,deg_to_rad(rot))
	
	mesh_container.rotation_degrees.z = lerpf(
		mesh_container.rotation_degrees.z, 
		-yaw_input * 50, yaw_rotate_delta*delta)

	if(Input.is_action_just_pressed("ui_accept")):
		rot = 0

	quaternion = quaternion.slerp(yaw_quat *  pitch_quat, delta)
	print(basis, " - " ,global_basis)
