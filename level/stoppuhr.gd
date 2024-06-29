extends Node
@onready var label = $label
@onready var active = true

var speedrun_time
var time

func _ready():
	speedrun_time = 0
	time = speedrun_time

func _physics_process(delta):
	if active:
		time = float(time) + delta
		update_ui()

func update_ui():
	var formatted_time = format_time(time)
		
	label.text = formatted_time

func format_time(zeit):
	var formatted_time = str(zeit)
	var decimal_index = formatted_time.find(".")
	
	if decimal_index > 0:
		formatted_time = formatted_time.left(decimal_index + 3)
		speedrun_time = formatted_time
	return formatted_time
