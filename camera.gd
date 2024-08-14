extends Node3D

@export var follow_target:Node3D
@export var pitch_min:float = -50
@export var pitch_max:float = 50
@export var pitch_sensi = 0.002
@export var yaw_sensi = 0.002

@onready var spring_arm_3d = $CameraTarget/SpringArm3D
@onready var camera_target = $CameraTarget
@onready var camera_3d = $CameraTarget/SpringArm3D/Camera3D


var yaw:float
var pitch:float
var cam_target_basis:Basis

# Called when the node enters the scene tree for the first time.
func _ready():
	camera_3d.position.z = spring_arm_3d.spring_length
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera_target.global_position = follow_target.global_position


func _physics_process(delta):
	handle_cam(delta)

func handle_cam(delta):
	pitch = clamp(pitch, pitch_min, pitch_max)

	spring_arm_3d.rotation_degrees.y = lerpf(
		spring_arm_3d.rotation_degrees.y, yaw, 10*delta)
		
	spring_arm_3d.rotation_degrees.x = lerpf(
		spring_arm_3d.rotation_degrees.x, pitch, 10*delta)

	
	camera_target.global_position = follow_target.global_position
	cam_target_basis = lerp(
		camera_target.basis.orthonormalized(),
		follow_target.basis.orthonormalized(), delta * 2)
	camera_target.basis = cam_target_basis.orthonormalized()
func _input(event):
	if ((event is InputEventMouseMotion) and (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED)):
		yaw += -event.relative.x * yaw_sensi
		pitch += event.relative.y * pitch_sensi
