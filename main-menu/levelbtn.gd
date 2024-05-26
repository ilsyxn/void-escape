extends TextureButton
@onready var star = $Star
@onready var save_Game = preload("res://save/saveGame.tres")

@export var id : int

func _ready():
	disabled = true

func _process(_delta):
	if save_Game.unlockedLevels.has(id):
		disabled = false
	
	if disabled == true:
		star.visible = false
	else:	
		if save_Game.bonusItems.has(id):
			star.texture = load("res://assets/star.png")
		else: 
			star.texture = load("res://assets/star_locked.png")
	
