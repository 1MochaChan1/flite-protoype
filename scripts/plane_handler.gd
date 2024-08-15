extends RigidBody3D

@export var base_speed:float=60
@export var dive_throttle:float=5

@export var max_horizontal_speed:float = 300
@export var max_vertical_speed:float = 500
@export var max_rise:float=100

# Input
var yaw_input:float
var pitch_input:float


var right_dir:Vector3
var forward_dir:Vector3
var upward_dir:Vector3

var rise_meter:float
var adjustment_meter:float

# Velocity
var last_dive_vel:float
var horizontal_vel:Vector3
var vertical_vel:Vector3


@onready var state = $"../CanvasLayer/Control/State"
@onready var mesh_container = $MeshContainer
@onready var collision_shape_3d = $CollisionShape3D


func _physics_process(delta):
	forward_dir = transform.basis.z
	vertical_vel = Vector3(0,linear_velocity.y,0)
	horizontal_vel = Vector3(linear_velocity.x, 0, linear_velocity.z)
	right_dir = transform.basis.x
	
	handle_input(delta)
	apply_physics(delta)
	steer()
	#test_local_linear_vel()
	$"../CanvasLayer/Control/Velocity".text = "Velocity: "+str(linear_velocity)


func handle_input(delta):
	pitch_input = Input.get_axis("ui_down", "ui_up")
	yaw_input = Input.get_axis("ui_right","ui_left")


func apply_physics(delta):
	if(pitch_input>0):
		diving()
	elif(pitch_input<0 and rise_meter>0):
		rising()
	else:
		gliding()
	var temp_max_vel = horizontal_vel.normalized() * max_horizontal_speed
	if (linear_velocity.length() > max_horizontal_speed):
		apply_impulse(-horizontal_vel.normalized() * 6)

func diving():
	upward_dir = transform.basis.y
	state.text = "State: Diving"
	mesh_container.rotation_degrees.x = lerpf(
		mesh_container.rotation_degrees.x, pitch_input * 90, .05)
	
	apply_central_impulse(-upward_dir * dive_throttle)
	apply_central_impulse(-forward_dir * 0.05)
	rise_meter += 0.05
	adjustment_meter += 1
	rise_meter = clamp(rise_meter, 0, 5)
	adjustment_meter = clamp(adjustment_meter, 0, 100)


func rising():
	state.text = "State: Rising"
	mesh_container.rotation_degrees.x = lerpf(
		mesh_container.rotation_degrees.x, pitch_input * 90, .05)
	if(rise_meter>0):
		apply_central_impulse(upward_dir * 7)
		apply_central_impulse(-forward_dir * 4)
		rise_meter -= .1


func gliding():
	state.text = "State: Gliding"
	mesh_container.rotation_degrees.x = lerpf(
		mesh_container.rotation_degrees.x, 0, .05)
	last_dive_vel = maxf(vertical_vel.length(), horizontal_vel.length())
	apply_central_impulse(forward_dir * 1.5)
	
	
	if (adjustment_meter>0):
		#apply_central_impulse()
		apply_central_impulse(
			(forward_dir * adjustment_meter * 2)
			 + (upward_dir * -linear_velocity.y * 0.7))
		adjustment_meter = 0
	
# CRITICAL: how to turn without looking stupid
func steer():

	mesh_container.rotation_degrees.z = lerp(
		mesh_container.rotation_degrees.z, -yaw_input * 70, 0.075)
	
	var torque_dir = transform.basis.y
	angular_velocity.y = lerp(angular_velocity.y, yaw_input * 1.5, 0.5)
	if(yaw_input != 0):
		apply_central_impulse(right_dir  * yaw_input * 5)
		apply_central_impulse(forward_dir * 2)
	
	rise_meter += 0.001
