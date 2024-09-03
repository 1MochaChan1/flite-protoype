class_name GameManager
extends Node

# Can change scene
# Responsible for saving game files
var _level:PackedScene
var curr_level:CustomScene

static var save_game:SaveGame 

func _ready() -> void:
	_level = preload("res://scenes/menu.tscn")
	curr_level = _level.instantiate()
	add_child(curr_level)
	curr_level.call_scene_change.connect(load_level)
	save_game = load("res://resources/default_save.tres")
	# TODO: Load saved game here, else use the default save.

func unload_level():
	if(is_instance_valid(curr_level)):
		curr_level.queue_free()
	curr_level = null

func load_level(next_scene:String):
	unload_level()
	var _path:= next_scene
	_level = load(_path)
	if(_level):
		curr_level = _level.instantiate()
		add_child(curr_level)
		curr_level.call_scene_change.connect(load_level)
		print(save_game.level_stats)

static func get_save_game_file() -> SaveGame:
	return save_game

static func update_save_game_file(new_save_game:SaveGame) -> SaveGame:
	save_game = new_save_game
	return save_game
