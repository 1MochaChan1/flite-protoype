#class_name GameManager
extends Node

# Can change scene
# Responsible for saving game files
var _level:PackedScene
var curr_level:CustomScene

static var save_game:SaveGame 

func _ready() -> void:
	
	# TODO: Load saved game here, else use the default save.
	if SaveGame.save_exist():
		save_game = SaveGame.load_savegame() as SaveGame
		
	else:
		var temp = load("res://resources/default_save.tres")
		save_game = temp.duplicate()
		save_game.write_savegame()

static func get_save_game_file() -> SaveGame:
	return save_game

static func update_save_game_file(new_save_game:SaveGame) -> SaveGame:
	save_game = new_save_game
	return save_game
