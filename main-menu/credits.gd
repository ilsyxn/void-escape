extends Node2D

func _process(delta):
	if Input.is_action_just_pressed("enter"):
		get_tree().change_scene_to_file("res://main-menu/main.tscn")
func _on_back_pressed():
	get_tree().change_scene_to_file("res://main-menu/main.tscn")
