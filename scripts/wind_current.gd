extends Area3D

@onready var marker_3d: Marker3D = $Marker3D

var wind_current_dir:Vector3
var is_once:bool = false 
func _ready() -> void:
	wind_current_dir = marker_3d.global_position


func _on_body_entered(body: Node3D) -> void:
	print(body)
	if ((body is Player) and not is_once):
		is_once = true
		body._move_in_wind_direction(wind_current_dir)


func _on_body_exited(body: Node3D) -> void:
	is_once = false
