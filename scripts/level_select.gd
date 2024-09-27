extends CustomScene

@export var grid: GridContainer

var tile_ins = preload("res://scenes/UI/btn_level_select.tscn")

func _ready() -> void:
	_gen_tiles()

 

func _start_level(level_name=null):
	go_to_selected_level(level_name)

func _gen_tiles():
	var levels = GameManager.save_game.level_stats
	for key in levels.keys():
		var tile = tile_ins.instantiate()
		grid.add_child(tile)
		if(tile  is LevelSelectButton):
			tile.stars = levels[key]
			tile.level_name = key
			tile.level_no = key[-1]
			tile.handle_stars()
			tile.btn.pressed.connect(
				_start_level.bind(tile.level_name))
	pass


func _on_back_pressed() -> void:
	go_to_main_menu()
