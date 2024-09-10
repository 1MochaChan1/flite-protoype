class_name CustomScene extends Node3D

@export var is_level:bool=true
@export var scene_name:String

@export_category('PLayable Level Menu Option')
@export var game_end_menu:CanvasLayer
@export var pause_menu:CanvasLayer
@export var hud:CanvasLayer
@export var drops:Node

@export_category('PLayable Level Milestones')
## how many seconds for 1 star
@export var one_star:int = 20
## how many seconds for 2 star
@export var two_star:int = 50
## how many seconds for 3 star
@export var three_star:int = 60

var messages:int
var player:CharacterBody3D

var time_start = 0
var elapsed_time = 0

## Buttons for menus
var g_btn_restart:Button
var g_btn_main_menu:Button
var g_btn_next_level:Button
var p_btn_restart:Button
var p_btn_main_menu:Button
var p_btn_resume:Button

# These will be called by scenes or the scene_managers (only).
signal call_scene_change(next_scene:StringName)
signal call_scene_restart()

## NOTE: Edit for having the minimal functionality such as a Main Menu.
func _ready():
	get_tree().paused = false
	if(is_level):
		messages = drops.get_child_count()
		for drop in drops.get_children():
			if(drop is Drop):
				drop.message_dropped.connect(
					update_message_count)
		
		game_end_menu.visible = false
		pause_menu.visible = false
		
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		player = get_tree().get_nodes_in_group('Players')[0]
		var camera = get_tree().get_nodes_in_group('Cameras')[0]
		
		if(player is Player):
			player.crashed.connect(on_level_fail)
			if (not player.v_joystick):
				player.v_joystick = hud.get_node('Control/Movestick')
		
		if (camera is Camera):
			if (not camera.v_joystick):
				camera.v_joystick = hud.get_node('Control/Lookstick')
		
		g_btn_next_level = game_end_menu.get_node(
			"Control/VBoxContainer/Next Level")
		g_btn_main_menu = game_end_menu.get_node(
			"Control/VBoxContainer/Main Menu")
		g_btn_restart = game_end_menu.get_node(
			"Control/VBoxContainer/Restart")
		
		p_btn_resume = pause_menu.get_node(
			"Control/VBoxContainer/Resume")
		p_btn_main_menu = pause_menu.get_node(
			"Control/VBoxContainer/Main Menu")
		p_btn_restart = pause_menu.get_node(
			"Control/VBoxContainer/Restart")
		
		g_btn_main_menu.pressed.connect(go_to_main_menu)
		g_btn_restart.pressed.connect(restart_level)
		g_btn_next_level.pressed.connect(go_to_next_level)
		
		p_btn_main_menu.pressed.connect(go_to_main_menu)
		p_btn_restart.pressed.connect(restart_level)
		p_btn_resume.pressed.connect(resume_game)
		
		time_start = Time.get_unix_time_from_system()


func _process(_delta):
	#can_pause_level()
	if(not get_tree().paused and \
	is_level and \
	not game_end_menu.visible):
		resume_game()
	_calculate_et()

####################################
########## Custom Methods ##########
####################################

## Will work in playable levels.
func update_message_count():
	if(not is_level):
		return
	messages -= 1
	
	if(messages == 0):
		on_level_pass()


func pause_player_movement():
	if(player is Player):
		player.is_in_control = false


## Returns elapsed time since the level started
## Pauses when the level pauses.
func _calculate_et() -> float:
	if(not get_tree().paused):
		elapsed_time = Time.get_unix_time_from_system() - time_start 
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
	g_btn_next_level.visible=false


####### Menu Visibility Methods 👁 #######
func _input(event: InputEvent):
	if(Input.is_action_just_pressed("ui_cancel")\
	and not game_end_menu.visible and is_level):
		if(not get_tree().paused):
			pause_game()
		

func pause_game():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	pause_menu.visible = true
	get_tree().paused = true

func resume_game():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pause_menu.visible = false
	get_tree().paused = false

####### Menu Button Methods 🔘 #######
func go_to_next_level():
	var _lvl_number =int(str(scene_name)[-1]) + 1
	var next_level = "res://scenes/Levels/level_forest%s.tscn" %str(_lvl_number)
	get_tree().change_scene_to_packed(
		load(next_level))
	#call_scene_change.emit(next_level)

func go_to_main_menu():
	#call_scene_change.emit('res://scenes/level_select.tscn')
	get_tree().change_scene_to_packed(
		preload('res://scenes/level_select.tscn'))


func restart_level():
	var _scene = "res://scenes/Levels/%s.tscn" % scene_name
	get_tree().change_scene_to_packed(
		load(_scene))
