extends Node2D
@export var map_position : Vector2i
@export var index : int
@export var connected_portal: Vector2i
@export var farbe : GradientTexture1D
@onready var particles = $CPUParticles2D

func _ready():
	particles.color_ramp = farbe.gradient
	


