extends Control
@onready var resume = $VBoxContainer/Resume
@onready var quit = $VBoxContainer/Quit

@onready var enabled = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if enabled:
		resume.disabled = false
		quit.disabled = false
		visible = true
	if !enabled:
		resume.disabled = true
		quit.disabled = true
		visible = false


func _on_quit_pressed():
	get_tree().change_scene_to_file("res://main-menu/lvlSelect.tscn")


func _on_resume_pressed():
	enabled = false
