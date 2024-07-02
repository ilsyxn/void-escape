extends Sprite2D
@export var one_star : float
@export var two_stars : float
@export var three_stars : float

@onready var time2 = $Two_Stars/Time
@onready var time3 = $Three_Stars/Time
@onready var settings = $"../Settings"

func _ready():
	
	time2.text = str(two_stars) + ".0s"
	time3.text = str(three_stars) + ".0s"

func toggle():
	visible = !visible

func _unhandled_input(event):
	if event.is_action_pressed("help") and !settings.enabled:
		toggle()
