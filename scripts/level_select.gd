extends CustomScene

@export var grid: GridContainer

var tile_ins = preload("res://scenes/UI/btn_level_select.tscn")

func _ready() -> void:
	_gen_tiles()
	#var children = get_tree().get_nodes_in_group('LevelButtons')
	#for child in children:
		#if(child is LevelSelectButton):
			#child.pressed.connect(_start_level.bind(child.name))
			#child.star = "⭐%s" %GameManager\
			#.save_game.level_stats[child.name]
 

func _start_level(level_name=null):
	go_to_selected_level(level_name)

func _gen_tiles():
	var levels = GameManager.save_game.level_stats
	for key in levels.keys():
		var tile = tile_ins.instantiate()
		grid.add_child(tile)
		if(tile  is LevelSelectButton):
			tile.stars = levels[key]
			print(levels[key], ": ", key)
			tile.level_name = key
			tile.level_no = key[-1]
			tile.handle_stars()
			tile.btn.pressed.connect(
				_start_level.bind(tile.level_name))
	pass
