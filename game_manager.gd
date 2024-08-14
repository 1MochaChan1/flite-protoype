extends Node3D

@export var messages:=0

var current_messgaes
var player:CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_nodes_in_group('Player')[0]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
