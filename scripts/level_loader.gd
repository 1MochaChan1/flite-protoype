extends Control

@export var loading_bar: ProgressBar
@export var percentage_label:Label

var scene_path: String
var progress: Array

var update:float = 0.0

func _ready() -> void:
	scene_path = GameManager.next_level_path
	ResourceLoader.load_threaded_request(scene_path)

func _process(delta: float) -> void:
	ResourceLoader.load_threaded_get_status(scene_path, progress)

	if (progress[0]>update): update = progress[0]
	
	if (loading_bar.value < update): 
		loading_bar.value = lerp(
			loading_bar.value, update, delta)
		

	if(loading_bar.value>=.999):
		get_tree().change_scene_to_packed(
			ResourceLoader.load_threaded_get(scene_path)
		)
	
