class_name Drop
extends Node3D

signal message_dropped

func _on_area_3d_body_entered(body: Node3D) -> void:
	if(body is Player):
		message_dropped.emit()
		queue_free()
