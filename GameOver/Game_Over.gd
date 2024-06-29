extends Node2D
@onready var buttons = [$Marker1, $Marker2]
@onready var index = 0
@onready var border = $Border
@onready var active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	border.position = buttons[index].position


func _unhandled_input(event):
	if event.is_action_pressed("up") and active:
		index = 0
	elif event.is_action_pressed("down") and active:
		index = 1
	elif event.is_action_pressed("enter") and active:
		press_button(index)

func press_button(i : int):
	match i:
		0: _on_restart_pressed()
		1: _on_menu_pressed()
func bounce_in() -> void:
	active = true
	$".".set_physics_process(false)
	var tween = create_tween()
	
	# Change position x to 512 over 2 seconds
	# Also add a bounce at the end of the transition:
	tween.tween_property(self, "position:y", 350, 2.0).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


func _on_menu_pressed():
	get_tree().change_scene_to_file("res://main-menu/level_selector.tscn")


func _on_restart_pressed():
	$"../../lvl2_1".restartLevel()
