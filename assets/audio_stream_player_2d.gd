extends AudioStreamPlayer2D

var muted = false
@onready var staerke = volume_db
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event):
		if event.is_action_pressed("mute"):
			if !muted:
				staerke = volume_db
				volume_db = -80
				muted = true
			elif muted:
				volume_db = staerke
				muted = false
