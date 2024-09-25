class_name Player extends CharacterBody3D

## Joystick input from the current scene, can be overridden.
@export var v_joystick:VirtualJoystick

## Maximum speed the plane can achieve when diving.
@export var MAX_SPEED := 300.0

## Default cruising speed of the plane.
@export var MIN_SPEED := 25.0

## Acceleration rate when the airplane dives or rises.
@export var ACCELERATION := 10.0


@export_category("Orientation")

## Maximum pitch angle in degrees.
@export var max_pitch_angle := 75


@export_category("Rate")

## Yaw angle - how much the plane turns per second.
@export var yaw_angle := 20

# -- Constants -- #
const _YAW_RATE = 4
const _GRAVITY = 12

# -- Nodes -- #
@onready var _mesh_container = $MeshContainer
@onready var speedlines: ColorRect = $Speedlines

# -- Variables -- #
var _fwd
var _pitch_input: float = 0.0
var _yaw_input: float = 0.0
var _yaw: float = 0.0
var _tween: Tween
var _current_speed: float = 0.0
var is_in_control: bool = true
var _rise_meter: float = 0.0
var _accelerated_speed: float
#var _speedline_shader_transparency: float

# -- Signals -- #
signal crashed

## -- Ready Function -- ##
func _ready():
	# Initialize speed to minimum on start.
	_current_speed = MIN_SPEED


## -- Physics Process -- ##
func _physics_process(delta):
	if not is_in_control:
		return
	_handle_input()
	_handle_physics(delta)
	_handle_rotation(delta)
	_handle_animation()


## -- Input Handling -- ##
func _handle_input():
	# Detect input from the virtual joystick or fallback to keyboard.
	if OS.get_model_name() != "GenericDevice":
		_pitch_input = v_joystick.output.y
		_yaw_input = -v_joystick.output.x
	else:
		_pitch_input = Input.get_axis("ui_down", "ui_up")
		_yaw_input = Input.get_axis("ui_right", "ui_left")


## -- Physics Handling -- ##
func _handle_physics(delta):
	# Forward vector of the plane
	_fwd = self.basis.z
	
	# Manage rise and dive behavior.
	if _pitch_input > 0:
		_rise_meter += delta * 2
	elif _pitch_input < 0:
		if _rise_meter > 0:
			_rise_meter -= delta * 2
		else:
			_pitch_input = 0
	
	_rise_meter = clamp(_rise_meter, 0, 10)
	
	# Calculate acceleration based on pitch input.
	_accelerated_speed = abs(_current_speed + (_pitch_input * ACCELERATION))
	
	# Adjust current speed based on pitch or return to minimum speed.
	if _pitch_input != 0:
		_current_speed = lerp(_current_speed, _accelerated_speed, delta * 6)
	else:
		_current_speed = lerp(_current_speed, MIN_SPEED, delta * 0.1)
	
	_current_speed = clamp(_current_speed, MIN_SPEED, MAX_SPEED)
	
	## Final velocity with gravity effect.
	velocity = _fwd * _current_speed
	velocity.y -= _GRAVITY * 10 * delta
	
	move_and_slide()


## -- Rotation Handling -- ##
func _handle_rotation(delta):
	# Adjust yaw based on input or return to neutral.
	if _yaw_input != 0:
		_yaw += _yaw_input
	else:
		_yaw = lerpf(_yaw, 0, delta * _YAW_RATE)
	
	_yaw = clamp(_yaw, -yaw_angle, yaw_angle)


## -- Animation Handling -- ##
func _handle_animation():
	_control_speed_lines()
	
	# Kill the previous tween if it exists.
	if _tween:
		_tween.kill()
	
	# Create a new tween for rotation animation.
	_tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_parallel(true)
	_tween.tween_property(_mesh_container, "rotation_degrees:z", -_yaw_input * 45, 0.5)
	_tween.tween_property(self, 'rotation_degrees:x', _pitch_input * max_pitch_angle, 0.75)
	_tween.tween_property(self, 'rotation_degrees:y', _yaw, 0.2).as_relative()


# -- Helper Functions -- #

## Get the current speed as a normalized value.
func get_normalized_curr_speed() -> float:
	return abs(velocity.length() / (MAX_SPEED - MIN_SPEED))

## Control the visibility of speed lines based on the current speed.
func _control_speed_lines():
	if velocity.length() > MIN_SPEED:
		speedlines.material.set_shader_parameter("transparency", get_normalized_curr_speed())
	else:
		speedlines.material.set_shader_parameter("transparency", 0)


# -- External Factors -- #

## Called when the plane moves in a wind current.
func _move_in_wind_direction(dir: Vector3):
	## Adjust speed and orientation based on wind.
	_current_speed *= 1.5
	look_at(dir, Vector3.UP, true)

## Handle crash event when the plane collides with another object.
func _on_hurtbox_body_entered(_body: Node3D) -> void:
	if is_in_control:
		crashed.emit()
