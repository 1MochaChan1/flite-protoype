extends CustomScene

@onready var grid_container: GridContainer = $CanvasLayer/Control/GridContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var children = grid_container.get_children()
	for child in children:
		if(child is Button):
			child.pressed.connect(_start_level.bind(child.name))
			child.text += " ⭐:%s" %GameManager\
			.save_game.level_stats[child.name]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _start_level(level_name):
	var _level = "res://scenes/Levels/%s.tscn" % level_name
	call_scene_change.emit(_level)
