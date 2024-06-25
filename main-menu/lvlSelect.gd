extends Node2D

@onready var bonusItems : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):



func _on_lvl_1_pressed():
	get_tree().change_scene_to_file("res://level/world1/level_1.tscn")


func _on_lvl_2_pressed():
		get_tree().change_scene_to_file("res://level/world1/level_2.tscn")


func _on_lvl_3_pressed():
	get_tree().change_scene_to_file("res://level/world1/level_3.tscn")


func _on_lvl_4_pressed():
	get_tree().change_scene_to_file("res://level/world1/level_4.tscn")


func _on_lvl_5_pressed():
	get_tree().change_scene_to_file("res://level/world1/level_5.tscn")


func _on_back_pressed():
	get_tree().change_scene_to_file("res://main-menu/main.tscn")
