extends Node2D
@export var isOwned : bool
@export var id : int
@export var bild : Texture2D
@export var preis : int
@onready var knopf = $Knopf
@onready var background = $Background
@onready var skin = $Skin
@onready var owned = $Owned

signal select
func _ready():
	skin.texture = bild
func _process(_delta):
	if isOwned:
		owned.visible = true
	else:
		owned.visible = false



func _on_knopf_pressed():
	select.emit()
	
