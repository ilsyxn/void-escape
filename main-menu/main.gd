extends Node2D
@onready var save_Game = preload("res://save/saveGame.tres")
@onready var index = 0
@onready var buttons = [$Marker1, $Marker2, $Marker3, $Marker4]
@onready var border = $Border
func _ready():
	pass
func _process(_delta):
	border.position = buttons[index].position
	if Input.is_action_just_pressed("left"):
		move_border(true)
	if Input.is_action_just_pressed("right"):
		move_border(false)
	if Input.is_action_just_pressed("enter"):
		press_button(index)

func move_border(left :bool):
	if left and index != 0:
		index -= 1
	elif !left and index != 3:
		index += 1

func _on_play_pressed():
	get_tree().change_scene_to_file("res://main-menu/level_selector.tscn")


func _on_credits_pressed():
	get_tree().change_scene_to_file("res://main-menu/credits.tscn")


func _on_help_pressed():
	get_tree().change_scene_to_file("res://main-menu/help_menu.tscn")


func _on_skins_pressed():
	get_tree().change_scene_to_file("res://main-menu/shop.tscn")

func press_button(index):
	match index:
		0: _on_play_pressed()
		1: _on_skins_pressed()
		2: _on_credits_pressed()
		3: _on_help_pressed()


