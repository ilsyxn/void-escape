extends Node2D
@onready var save_Game = preload("res://save/saveGame.tres")
@onready var selected_skin = $ItemShop/SelectedSkin
@onready var marker = [$Marker1, $Marker2, $Marker3, $Marker4, $Marker5, $Marker6, $Marker7, $Marker8]
var marker_index = 0
@onready var border = $Border
@onready var slots = [$VBoxContainer/HBoxContainer/Slot0, $VBoxContainer/HBoxContainer/Slot1, $VBoxContainer/HBoxContainer2/Slot2, $VBoxContainer/HBoxContainer2/Slot3, $VBoxContainer/HBoxContainer3/Slot4, $VBoxContainer/HBoxContainer3/Slot5, $VBoxContainer/HBoxContainer4/Slot6, $VBoxContainer/HBoxContainer4/Slot7]
@onready var preis = $ItemShop/Preis
@onready var star = $ItemShop/Star
@onready var owned = $ItemShop/Owned
@onready var action = $ItemShop/Action

func _process(delta):
	if slots[marker_index].isOwned:
		action.position = Vector2(-753.333, 560)
		action.text = "Press Enter to equip"
	else: 
		action.position = Vector2(-700, 560)
		action.text = "Press Enter to buy"
	if save_Game.equipped_skin == slots[marker_index].id:
		action.text = "     Skin is equipped."
	owned.text = str(save_Game.collected_stars)
	border.global_position = marker[marker_index].global_position
	selected_skin.texture = slots[marker_index].skin.texture
	if slots[marker_index].isOwned:
		preis.visible = false
		star.visible = false
	if marker_index == 7:
		preis.visible = false
		star.visible = false
		if !slots[marker_index].isOwned:
			action.text = "collect all stars\n          in world 1"
	else:
		preis.visible = true
		star.visible = true
		preis.text = str(slots[marker_index].preis)

func _ready():
	if save_Game.bonusUnlocked() and !save_Game.owned_skins.has(7):
		save_Game.owned_skins.append(7)
		slots[7].isOwned = true

func _unhandled_input(event):
	if event.is_action_pressed("back"):
		get_tree().change_scene_to_file("res://main-menu/main.tscn")
	if event.is_action_pressed("left"):
		move_border(true)
	if event.is_action_pressed("right"):
		move_border(false)
	if event.is_action_pressed("enter"):
		if !slots[marker_index].isOwned:
			buy_skin()
		else: 
			save_Game.equip_skin(slots[marker_index].id)

func buy_skin():
	if save_Game.collected_stars >= slots[marker_index].preis:
		save_Game.collected_stars -= slots[marker_index].preis
		save_Game.owned_skins.append(marker_index)
		slots[marker_index].isOwned = true
		
		

func move_border(left : bool):
	if left and marker_index != 0:
		marker_index -= 1
	if !left and marker_index != 7:
		marker_index += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.


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
