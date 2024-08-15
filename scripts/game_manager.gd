extends Node3D

@export var messages:=0

var current_messgaes
var player:CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player = get_tree().get_nodes_in_group('Player')[0]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(
		Input.is_action_just_pressed("ui_cancel") 
		and (Input.mouse_mode == Input.MOUSE_MODE_CAPTURED)):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif (Input.is_action_just_pressed("ui_cancel") 
		and (Input.mouse_mode == Input.MOUSE_MODE_VISIBLE)):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
