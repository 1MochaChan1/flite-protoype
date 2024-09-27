class_name CustomScene extends Node3D

@export var is_level:bool=true
@export var scene_name:String

@export_category('PLayable Level Menu Option')
@export var game_end_menu:GameEndMenu
@export var pause_menu:PauseMenu
@export var hud:HUD
@export var drops:Node

@export_category('PLayable Level Milestones')
## how many seconds for 1 star
@export var one_star:int = 20
## how many seconds for 2 star
@export var two_star:int = 50
## how many seconds for 3 star
@export var three_star:int = 60

@export_category("Sounds")
@export var ambience_bg:AudioStreamPlayer


var total_messages:int
var _curr_message:int=0
var player:CharacterBody3D

var time_start = 0
var elapsed_time = 0

## Buttons for menus
var g_btn_restart:Button
var g_btn_level_select:Button
var g_btn_next_level:Button
var p_btn_restart:Button
var p_btn_level_select:Button
var p_btn_resume:Button


# These will be called by scenes or the scene_managers (only).
signal call_scene_change(next_scene:StringName)
signal call_scene_restart()


## NOTE: Edit for having the minimal functionality such as a Main Menu.
func _ready():
	get_tree().paused = false
	if(ambience_bg): ambience_bg.play()
	if(is_level):
		total_messages = drops.get_child_count()
		for drop in drops.get_children():
			if(drop is Drop):
				drop.message_dropped.connect(
					update_message_count)
		
		game_end_menu.visible = false
		pause_menu.visible = false
		
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		player = get_tree().get_nodes_in_group('Players')[0]
		var camera = get_tree().get_nodes_in_group('Cameras')[0]
		
		# -- Handling HUD -- #
		hud.txt_message = "%s/%s" %[_curr_message,total_messages]
		
		
		# Assign the joystick if it's not assigned already
		if(player is Player):
			player.crashed.connect(on_level_fail)
			if (not player.v_joystick):
				player.v_joystick = hud.move_stick
		
		if (camera is Camera):
			if (not camera.v_joystick):
				camera.v_joystick = hud.look_stick
		
		
		game_end_menu.btn_level_select.custom_pressed.connect(go_to_level_select)
		game_end_menu.btn_restart.custom_pressed.connect(restart_level)
		game_end_menu.btn_next_level.custom_pressed.connect(go_to_next_level)
		
		pause_menu.btn_level_select.custom_pressed.connect(go_to_level_select)
		pause_menu.btn_restart.custom_pressed.connect(restart_level)
		pause_menu.btn_resume.custom_pressed.connect(resume_game)
		
		hud.pause_btn.pressed.connect(pause_game)
		
		time_start = Time.get_unix_time_from_system()


func _process(_delta):
	
	#can_pause_level()
	if(not get_tree().paused and \
	is_level and \
	not game_end_menu.visible):
		resume_game()
	_calculate_et(_delta)

####################################
########## Custom Methods ##########
####################################

## Will work in playable levels.
func update_message_count():
	if(not is_level):
		return
	_curr_message += 1
	hud.txt_message = "%s/%s" %[_curr_message,total_messages]
	if(total_messages == _curr_message):
		on_level_pass()


func pause_player_movement():
	if(player is Player):
		player.is_in_control = false


## Returns elapsed time since the level started
## Pauses when the level pauses.
func _calculate_et(delta) -> float:
	if(not get_tree().paused and is_level):
		#elapsed_time = Time.get_unix_time_from_system() - time_start
		elapsed_time += delta
		var min = int(elapsed_time / 60)
		var sec = fmod(elapsed_time, 60)
		hud.txt_timer = "%02d:%02d" % [min, sec]
	return elapsed_time

func get_current_stars() -> int:
	if(elapsed_time < three_star):
		return 3
	elif(elapsed_time < two_star):
		return 2
	return 1


####### Level Methods 🧱 #######
func on_level_pass():
	if(not is_level and game_end_menu.visible):
		return
	pause_player_movement()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	game_end_menu.visible = true
	var _save_game = GameManager.save_game
	var level_star = _save_game.level_stats[scene_name]
	
	var cur_stars = get_current_stars()
	if(cur_stars > level_star):
		_save_game.level_stats[scene_name] = cur_stars
		GameManager.save_game.write_savegame()

func on_level_fail():
	if(game_end_menu.visible):
		return
	pause_player_movement()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	game_end_menu.visible = true
	game_end_menu.btn_next_level.visible=false




####### Menu Visibility Methods 👁 #######
func _input(event: InputEvent):
	if(Input.is_action_just_pressed("ui_cancel")\
	and not game_end_menu.visible and is_level):
		pause_game()

func pause_game():
	if(get_tree().paused): return
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	pause_menu.visible = true
	get_tree().paused = true

func resume_game():
	if(not get_tree().paused): return
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pause_menu.visible = false
	get_tree().paused = false

####### Menu Button Methods 🔘 #######
func go_to_next_level():
	var _lvl_number =int(str(scene_name)[-1]) + 1
	#TODO: Make this dynamic with a next_level variable
	var next_level = "res://scenes/Levels/level_forest%s.tscn" %str(_lvl_number)
	_change_level_with_loader(next_level)
	#if(ResourceLoader.exists(next_level)):
		#get_tree().change_scene_to_packed(
			#load(next_level))
	#else:
		#printerr("Path to next level is invalid")
	#call_scene_change.emit(next_level)

func go_to_main_menu():
	get_tree().change_scene_to_packed(
		preload("res://scenes/UI/menu.tscn"))

func go_to_level_select():
	get_tree().paused = false
	get_tree().change_scene_to_packed(
		preload("res://scenes/UI/level_select.tscn"))

func go_to_selected_level(level_name:String):
	var _level = "res://scenes/Levels/%s.tscn" % level_name
	_change_level_with_loader(_level)
	#get_tree().change_scene_to_packed(
		#load(_level))



func restart_level():
	var _scene = "res://scenes/Levels/%s.tscn" % scene_name
	get_tree().change_scene_to_packed(
		load(_scene))

func _change_level_with_loader(scene_path):
	GameManager.next_level_path = scene_path
	if(ResourceLoader.exists(scene_path)):
		get_tree().change_scene_to_packed(
			load(GameManager.LOADER_PATH))
	else:
		printerr("Path to next level is invalid")
