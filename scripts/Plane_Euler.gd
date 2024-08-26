class_name Player extends CharacterBody3D

## Virtual joystick for mobile input.
@export var v_joystick:VirtualJoystick
## The max speed the plane can achieve when diving
@export var MAX_SPEED:=80.0
## The speed that the plane will run on mostly
@export var MIN_SPEED:=20.0

@export_category("Orientation")
## In Degrees
@export var max_pitch_angle:=75

@export_category("Rate")
## How much the plane turns per seconds
@export var yaw_angle:=25

const _YAW_RATE = 4
const _GRAVITY = 12


@onready var _mesh_container = $MeshContainer


var _fwd
var _up
var _rt

var _pitch_input:=.0
var _yaw_input:=.0
var _yaw:=.0
var _tween:Tween
var _current_speed:=.0

signal message_dropped

func _ready():
	_current_speed = MIN_SPEED
	


func _physics_process(delta):

	_handle_input()
	_handle_rotation(delta)
	_handle_animation()
	_handle_physics(delta)
	$"../CanvasLayer/Control/Velocity".text = str(velocity)


func _handle_input():
	
	if(OS.get_model_name() != "GenericDevice"):
		_pitch_input = v_joystick.output.y
		_yaw_input = -v_joystick.output.x
	else:
		_pitch_input = Input.get_axis("ui_down", "ui_up")
		_yaw_input = Input.get_axis("ui_right", "ui_left")


func _handle_physics(delta):
	
	_fwd=basis.z
	_up=basis.y
	_rt=basis.x
	
	if(_pitch_input != 0):
		_current_speed = lerp(
			_current_speed, _current_speed + (_pitch_input * 5), delta * 8)
	else:
		_current_speed = lerp(
			_current_speed, MIN_SPEED, delta * 0.05)
			
	_current_speed = clamp(_current_speed, MIN_SPEED, MAX_SPEED)
	
	velocity = _fwd * _current_speed 
	velocity.y -= _GRAVITY * 10 * delta
	
	move_and_slide()


func _handle_rotation(delta):
	if (_yaw_input != 0):
		_yaw += _yaw_input 
	else:
		_yaw = lerpf(_yaw, 0, delta * _YAW_RATE)
	_yaw = clamp(_yaw, -yaw_angle, yaw_angle)


func _handle_animation():
	if(_tween):
		_tween.kill() 
	_tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_parallel(true)
	_tween.tween_property(
		_mesh_container, "rotation_degrees:z", -_yaw_input * 45, .5)
	_tween.tween_property(
		self, 'rotation_degrees:x', _pitch_input * max_pitch_angle, .75)
	_tween.tween_property(self, 'rotation_degrees:y', _yaw, 0.2).as_relative()

## Called by the wind_current
func _move_in_wind_direction(dir:Vector3):
	# TODO: Do quaternion vodoo here.
	_current_speed *= 1.5
	look_at(dir, Vector3.UP, true)
