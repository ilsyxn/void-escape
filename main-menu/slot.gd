extends Node2D
@export var isOwned : bool
@export var id : int
@export var bild : Texture2D
@export var preis : int
@onready var knopf = $Knopf
@onready var background = $Background
@onready var skin = $Skin
@onready var owned = $Owned
@onready var save_Game = preload("res://save/saveGame.tres")

signal select
func _ready():
	if save_Game.owned_skins.has(id):
		isOwned = true
	skin.texture = bild
func _process(_delta):
	if isOwned:
		owned.visible = true
	else:
		owned.visible = false



func _on_knopf_pressed():
	select.emit()
	
