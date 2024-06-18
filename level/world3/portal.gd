extends Node2D
@export var map_position : Vector2i
@export var connected_portal: Vector2i
@export var color : Color
@onready var particles = $CPUParticles2D

func _ready():
	particles.self_modulate = color


