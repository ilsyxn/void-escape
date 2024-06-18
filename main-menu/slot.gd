extends Node2D

@onready var selected : bool = false
@onready var img = $Img
@onready var background = $Img/Background
@onready var skin = $Img/Skin
@onready var owned = $Img/Owned

@export var id : int
@export var isOwned : bool
@export var image : Texture2D

# Called when the node enters the scene tree for the first time.
func _ready():

	
	skin.texture = image
	if selected:
		img.texture = preload("res://assets/skins/slot-selected.png")
	elif !selected:
		img.texture = preload("res://assets/skins/slot.png")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if selected:
		img.texture = preload("res://assets/skins/slot-selected.png")
	elif !selected:
		img.texture = preload("res://assets/skins/slot.png")
		
	if isOwned:
		owned.visible = true
	elif !isOwned:
		owned.visible = false
