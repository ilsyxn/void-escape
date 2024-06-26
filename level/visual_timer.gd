extends Node
@onready var timer = $Timer
@onready var time = $time


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	time.text = "%02d:%02d" % time_on_clock()


func time_on_clock():
	var time_left = timer.time_left
	var second = int(time_left)% 60
	var mil_second = int((time_left - int(time_left)) * 100)
	return [second, mil_second]
