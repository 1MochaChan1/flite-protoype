class_name CustomScene extends Node3D


@export var is_level:bool=true

@export_category('PLayable Level Menu Option')
@export var menus:CanvasLayer
@export var btn_restart:Button
@export var btn_main_menu:Button
@export var btn_next_level:Button
@export var messages:=0
@export var label:Label

@export_category('PLayable Level Milestones')
## how many seconds for 1 star
@export var one_star:int
## how many seconds for 2 star
@export var two_star:int
## how many seconds for 3 star
@export var three_star:int

var current_messgaes:int
var player:CharacterBody3D

var time_start = 0
var elapsed_time = 0
var is_paused := false


# These will be called by scenes or the scene_managers (only).
signal call_scene_change(next_scene:StringName)
signal call_scene_restart()

## NOTE: Edit for having the minimal functionality such as a Main Menu.
func _ready():
	if(label):
		label.text += ": "+str(messages) 
	
	if(is_level):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
		if(len(get_tree().get_nodes_in_group('Player')) > 0):
			player = get_tree().get_nodes_in_group('Player')[0]
			if(player is Player):
				player.message_dropped.connect(update_message_count)
				player.crashed.connect(on_level_fail)
		
		if(menus):
			btn_main_menu.pressed.connect(go_to_main_menu)
			btn_restart.pressed.connect(restart_level)
			btn_next_level.pressed.connect(go_to_next_level)
	
		time_start = Time.get_unix_time_from_system()


func _process(_delta):
	can_pause_level()
	get_tree().paused = is_paused
	_calculate_et()

## Will work in playable levels.
func update_message_count():
	if(not is_level):
		return
	messages -= 1
	label.text = "Messages: "+str(messages)
	if(messages == 0):
		on_level_pass()

func can_pause_level():
	if(Input.is_action_just_pressed("ui_cancel") 
		and (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED)):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		#is_paused = true
	elif (Input.is_action_just_pressed("ui_cancel") 
		and (Input.mouse_mode == Input.MOUSE_MODE_VISIBLE)):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		#is_paused = false

func pause_player_movement():
	if(player is Player):
		player.is_in_control = false

func on_level_pass():
	if(not is_level and menus.visible):
		return
	#pause_player_movement()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	menus.visible = true
	
	var _save_game = GameManager.save_game
	var level_star = _save_game.level_stats[self.name]
	# check if eligble for next level
	var current_star = get_current_stars()
	
	if(current_star > level_star):
		GameManager.save_game.level_stats[self.name] = current_star
		print(current_star)
	## TODO: Please change the naming convention for the levels.
	## TODO: Also add saving to file. + Cleanup code.
	var _lvl_number =int(str(self.name)[-1]) + 1
	print(GameManager.get_save_game_file().level_stats[self.name])


func on_level_fail():
	if(not is_level and menus.visible):
		return
	pause_player_movement()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	menus.visible = true


## Returns elapsed time since the level started
## Pauses when the level pauses.
func _calculate_et() -> float:
	if(not is_paused):
		elapsed_time = Time.get_unix_time_from_system() - time_start 
	return elapsed_time

func get_current_stars() -> int:
	print(elapsed_time)
	print(three_star)
	if(elapsed_time < three_star):
		return 3
	elif(elapsed_time < two_star):
		return 2
	return 1

####### Menu Button Methods #######
func go_to_next_level():
	var _save_game = GameManager.save_game
	var level_star = _save_game.level_stats[self.name]
	# check if eligble for next level
	var current_star = get_current_stars()
	var _lvl_number =int(str(self.name)[-1]) + 1
	
	var next_level = "res://scenes/Levels/level_forest%s.tscn" %str(_lvl_number)
	call_scene_change.emit(next_level)
	

func go_to_main_menu():
	call_scene_change.emit('res://scenes/level_select.tscn')
	# on main menu check game file to see which levels are playable

func restart_level():
	var _scene = "res://scenes/Levels/%s.tscn" % self.name
	call_scene_change.emit(_scene)
