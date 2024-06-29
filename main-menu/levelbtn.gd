extends TextureButton
@onready var star = $Star
@onready var save_Game = preload("res://save/saveGame.tres")
var star_texture
@onready var border = $BorderLvl


@export var id : int
@export var welt : int

func _ready():
	disabled = true
	star_texture = get_star()

func _process(_delta):
	if save_Game.unlockedLevels.has(id):
		disabled = false
	
	if disabled == true:
		star.visible = false
	else:	
		if save_Game.bonusItems.has(id):
			star.texture = load(star_texture)
		else: 
			star.texture = load("res://assets/star_locked.png")

func get_star():
	match welt:
		1: return "res://assets/star.png"
		2: return "res://assets/buttons/orange/starorgange.png"
		3: return "res://assets/buttons/gray/stargray.png"
