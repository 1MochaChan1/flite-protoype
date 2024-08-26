class_name CustomScene extends Node3D

@export var messages:=0
@export var label:Label

var current_messgaes:int
var player:CharacterBody3D

# These will be called by the player or by the scene manager.
signal call_scene_change(next_scene:StringName)
signal call_scene_restart()

## NOTE: Edit for having the minimal functionality such as a Main Menu.
func _ready():
	if(label):
		label.text += ": "+str(messages) 
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if(len(get_tree().get_nodes_in_group('Player')) > 0):
		player = get_tree().get_nodes_in_group('Player')[0]
		if(player is Player):
			player.message_dropped.connect(update_message_count)

func _process(delta):
	if(Input.is_action_just_pressed("ui_cancel") 
		and (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED)):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif (Input.is_action_just_pressed("ui_cancel") 
		and (Input.mouse_mode == Input.MOUSE_MODE_VISIBLE)):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


## Will work in playable levels.
func update_message_count():
	messages -= 1
	label.text = "Messages: "+str(messages) 
