extends Node

# Can change scene
# Responsible for saving game files


var _level:PackedScene
var curr_level:CustomScene

func _ready() -> void:
	_level = preload("res://scenes/menu.tscn")
	curr_level = _level.instantiate()
	add_child(curr_level)
	curr_level.call_scene_change.connect(load_level)
	

func unload_level():
	if(is_instance_valid(curr_level)):
		curr_level.queue_free()
	curr_level = null

func load_level(next_scene:StringName):
	unload_level()
	var _path:= "res://scenes/%s.tscn" % next_scene
	_level = load(_path)
	if(_level):
		curr_level = _level.instantiate()
		add_child(curr_level)
		curr_level.call_scene_change.connect(load_level)
		
	
