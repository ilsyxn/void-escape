extends Node2D
@onready var slots = [$VBoxContainer/HBoxContainer/Slot, $VBoxContainer/HBoxContainer/Slot2,
 $VBoxContainer/HBoxContainer2/Slot3, $VBoxContainer/HBoxContainer2/Slot4,
 $VBoxContainer/HBoxContainer3/Slot5, $VBoxContainer/HBoxContainer3/Slot6,
 $VBoxContainer/HBoxContainer4/Slot7, $VBoxContainer/HBoxContainer4/Slot8]
@onready var counter = 0
@onready var selectedSlot = slots[0]
@onready var selection = $Selection
@onready var background = $Selection/Background
@onready var skin = $Selection/Skin
@onready var selectedSkin = selectedSlot.skin.texture
@onready var buttonSpot = $ButtonSpot
@onready var equip = $Equip
@onready var buy = $Buy
@onready var hiddenSpot = $HiddenSpot
@onready var save_Game = preload("res://save/saveGame.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	skin.texture = save_Game.selectedSkinText
	selectedSlot.selected = true
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if selectedSlot.isOwned:
		buy.global_position = hiddenSpot.global_position
		equip.global_position = buttonSpot.global_position
	elif !selectedSlot.isOwned:
		equip.global_position = hiddenSpot.global_position
		buy.global_position = buttonSpot.global_position
func _unhandled_input(event):
		if event.is_action_pressed("right"):
			switchSlot(false)
		elif event.is_action_pressed("left"):
			switchSlot(true)

func switchSlot(left: bool):
	slots[counter].selected = false
	if left:
		if counter == 0:
			counter = 7
		else:
			counter -= 1
	elif !left:
		if counter == 7:
			counter = 0
		else:
			counter += 1
	selectedSlot = slots[counter]
	selectedSlot.selected = true


func _on_equip_pressed():
	skin.texture = selectedSlot.skin.texture
	save_Game.setSkin(selectedSlot.id)
	save_Game.selectedSkinText = selectedSlot.skin.texture


func _on_back_pressed():
	get_tree().change_scene_to_file("res://main-menu/main.tscn")
