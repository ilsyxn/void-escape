extends Node2D
@export var map_position : Vector2i
@export var connected_portal: Vector2i
@export var farbe : GradientTexture1D
@onready var particles = $GPUParticles2D

func _ready():
	particles.process_material.color_ramp.gradient = farbe.gradient
	


