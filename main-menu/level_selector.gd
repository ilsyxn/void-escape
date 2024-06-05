extends Node2D
@onready var welten = [$World1, $World2]
@onready var world_1 = $World1
@onready var world_2 = $World2


func _on_rechts_pressed():
	var temp = world_1.global_position
	world_1.global_position = world_2.global_position




func _on_back_pressed():
	get_tree().change_scene_to_file("res://main-menu/main.tscn")
