class_name Drop
extends Node3D
@onready var sfx_pickup: AudioStreamPlayer = $Pickup

signal message_dropped

func _on_area_3d_body_entered(body: Node3D) -> void:
	if(body is Player):
		visible=false
		message_dropped.emit()
		sfx_pickup.play()

func _sfx_finished() -> void:
	queue_free()
