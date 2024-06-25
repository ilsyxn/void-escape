extends Node2D
@onready var buttons = [$VBoxContainer/HBoxContainer/Play, 
$VBoxContainer/HBoxContainer/Skins, 
$VBoxContainer/HBoxContainer2/Credits, 
$VBoxContainer/HBoxContainer2/Help]
@onready var save_Game = preload("res://save/saveGame.tres")
@onready var index = 0
func _ready():
	pass
func _process(_delta):
	if Input.is_action_just_pressed("controller"): 
		save_Game.controller = true
	if Input.is_action_just_pressed("up") and save_Game.controller:
		pass
	if Input.is_action_just_pressed("down") and save_Game.controller:
		pass
	if Input.is_action_just_pressed("left") and save_Game.controller:
		pass
	if Input.is_action_just_pressed("right") and save_Game.controller:
		pass
	if Input.is_action_just_pressed("controller_accept") and save_Game.controller:
		press_button(index)

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


