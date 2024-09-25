class_name LevelSelectButton extends Control

@onready var star_1: Sprite2D = $LevelSelectButton/Star1
@onready var star_2: Sprite2D = $LevelSelectButton/Star2
@onready var star_3: Sprite2D = $LevelSelectButton/Star3
@onready var btn: Button = $LevelSelectButton

@export var level_name:String
@export var level_no:int=0
@export var stars:int=0:
	set(val):
		stars = val
		handle_stars()
	get():
		return stars

func _ready() -> void:
	btn.text=str(level_no)
	handle_stars()

func handle_stars():
	btn.text=str(level_no)
	if(stars>2):
		_display_three_star()
	elif (stars>1):
		_display_two_star()
	elif (stars>0):
		_display_one_star()
	else:
		_display_zero_star()

func _display_zero_star():
	star_1.visible = false
	star_2.visible = false
	star_3.visible = false

func _display_one_star():
	star_1.visible = true
	star_2.visible = false
	star_3.visible = false

func _display_two_star():
	star_1.visible = true
	star_2.visible = true
	star_3.visible = false

func _display_three_star():
	star_1.visible = true
	star_2.visible = true
	star_3.visible = true
