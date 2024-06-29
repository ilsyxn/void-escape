extends Control
@onready var resume = $VBoxContainer/Resume
@onready var quit = $VBoxContainer/Quit

@onready var enabled = false
@onready var buttons = [$VBoxContainer/Resume, $VBoxContainer/Quit]
@onready var index = 0
@onready var border = $Border
@onready var marker = [$Marker1, $Marker2, $Marker3, $Marker4]
@onready var slider = $HSlider
@onready var sphere = $Sphere
@onready var slider2 = $HSlider2

# Called when the node enters the scene tree for the first time.
func _ready():
	border.position = $Marker1.position

func _unhandled_input(event):
	if event.is_action_pressed("up") and enabled:
		move_index(true)
	elif event.is_action_pressed("down") and enabled:
		move_index(false)
	elif event.is_action_pressed("enter") and enabled:
		press_button(index)
	elif event.is_action_pressed("right") and [2,3].has(index) and enabled:
		move_slider(false)
	elif event.is_action_pressed("left") and [2,3].has(index) and enabled:
		move_slider(true)

func move_slider(left : bool):
	if index == 2:
		if left: 
			slider.value -= 0.1
		if !left:
			slider.value += 0.1
	if index == 3:
		if left: 
			slider2.value -= 0.1
		if !left:
			slider2.value += 0.1
func move_index(up : bool):
	if up and index != 0:
		index -=1
	if !up and index != 3:
		index += 1

func press_button(i : int):
	match i:
		0: _on_resume_pressed()
		1: _on_quit_pressed()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if index == 0 or index == 1:
		border.visible = true
		sphere.visible = false
		border.position = marker[index].position
	if index == 2 or index == 3:
		sphere.visible = true
		border.hide()
	if index == 2 or index == 3:
		sphere.position = marker[index].position
	if enabled:
		resume.disabled = false
		quit.disabled = false
		visible = true
	if !enabled:
		resume.disabled = true
		quit.disabled = true
		visible = false


func _on_quit_pressed():
	get_tree().change_scene_to_file("res://main-menu/level_selector.tscn")


func _on_resume_pressed():
	enabled = false
