extends Sprite2D

@onready var stern_1 = $Stern1
@onready var stern_2 = $Stern2
@onready var stern_3 = $Stern3
@onready var cont = $Continue
var tween : Tween
@onready var required = $Required
@onready var highscore = $Highscore

@onready var save_Game = preload("res://save/saveGame.tres")
@onready var bounced = false

func _process(_delta):
	if bounced and Input.is_action_just_pressed("enter"):
		get_tree().change_scene_to_file("res://main-menu/level_selector.tscn")

func three_stars(id):
	stern_1.texture = preload("res://main-menu/star_gelb_big.png")
	stern_2.texture = preload("res://main-menu/star_gelb_big.png")
	stern_3.texture = preload("res://main-menu/star_gelb_big.png")
	if !save_Game.three_stars.has(id):
		save_Game.three_stars.append(id)
	addStars(3,id)

func two_stars(id):
	stern_1.texture = preload("res://main-menu/star_gelb_big.png")
	stern_2.texture = preload("res://main-menu/star_gelb_big.png")
	if !save_Game.two_stars.has(id):
		save_Game.two_stars.append(id)
		
	addStars(2,id)
func one_star(id):
	stern_1.texture = preload("res://main-menu/star_gelb_big.png")
	if !save_Game.one_star.has(id):
		save_Game.one_star.append(id)
	addStars(1,id)

func addStars(stars, id):
	if save_Game.stars_per_level[id] < stars:
		save_Game.collected_stars += stars - save_Game.stars_per_level[id] 
		save_Game.stars_per_level[id] = stars

func _on_continue_pressed():
	get_tree().change_scene_to_file("res://main-menu/level_selector.tscn")

func set_times(req, high):
	required.text += str(round_place(req, 2)) 
	highscore.text += str(round_place(high, 2)) 
	

func bounce_in() -> void:
	tween = create_tween()
	tween.tween_property(self, "position:y", 350, 2.0).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	bounced = true
	
func round_place(num,places):
	return (round(num*pow(10,places))/pow(10,places))
