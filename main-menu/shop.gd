extends Node2D
@onready var save_Game = preload("res://save/saveGame.tres")
@onready var selected_skin = $ItemShop/SelectedSkin

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	selected_skin.texture = save_Game.selectedSkinText


func _on_slot_0_select():
	pass # Replace with function body.


func _on_slot_1_select():
	pass # Replace with function body.


func _on_slot_2_select():
	pass # Replace with function body.


func _on_slot_3_select():
	pass # Replace with function body.


func _on_slot_4_select():
	pass # Replace with function body.


func _on_slot_5_select():
	
	pass # Replace with function body.


func _on_slot_6_select():
	pass # Replace with function body.


func _on_slot_7_select():
	pass # Replace with function body.
