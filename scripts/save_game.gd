class_name SaveGame
extends Resource

const SAVE_GAME_PATH := 'user://save.tres'

@export var level_stats:Dictionary

func write_savegame() -> void:
	ResourceSaver.save(self, SAVE_GAME_PATH)
	pass

static func save_exist() -> bool:
	return ResourceLoader.exists(SAVE_GAME_PATH)

static func load_savegame() -> Resource:
	if not ResourceLoader.has_cached(SAVE_GAME_PATH):
		return ResourceLoader.load(SAVE_GAME_PATH, "", 0)
	return null
