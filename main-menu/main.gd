extends Node2D

func _ready():
	pass
func _process(_delta):
	pass

func _on_play_pressed():
	get_tree().change_scene_to_file("res://main-menu/lvlSelect.tscn")


func _on_credits_pressed():
	pass # Replace with function body.
