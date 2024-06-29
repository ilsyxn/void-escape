extends TileMap

@onready var light = $"../Light"
@onready var light_out = $"../Belichtet/light_out"
@onready var light_out_in = $"../Belichtet/light_out_in"
@onready var light_timer = $"../visual_timer/Timer"
@onready var settings = $"../Belichtet/Settings"
@onready var stern_player = $"../SternPlayer"
@onready var info = $"../Belichtet/Info"
@onready var star_collected_text = $"../Belichtet/star_collected"

var tile_size = 32
var allowed_tile_ids = [30, 2, 3, 4, 8, 9, 34, 37]
var player_tile_pos
var timer_done = false
var early_start = false
@onready var bonus = false
@onready var betreten: Array = []
@onready var fog = $"../Fog"
@onready var star = $"../Belichtet/Star"
@onready var save_Game = preload("res://save/saveGame.tres")
@onready var player = save_Game.getWorld1Player()
@onready var particles = 0
@onready var bewertung = $"../Belichtet/Bewertung"

@export var id: int
@export var starPos: Vector2
@export var startPos: Vector2i

@onready var stoppuhr = $"../Belichtet/stoppuhr"
@onready var high_score_time = $"../Belichtet/HighScoreTime"
@export var three_stars: float
@export var two_stars: float
@onready var intro = $"../Intro"
@onready var new_highscore = $"../Belichtet/NewHighscore"
@onready var new_name_edit = $"../Belichtet/NewHighscore/VBoxContainer/HBoxContainer/NewNameEdit"
@onready var high_score = $"../Belichtet/Highscore2"
var highscore_global
var do_once = true

var scores = {
	"res://level/world1/level_1.tscn": {"score": 1.51, "level_id": 1.1},
	"res://level/world1/level_2.tscn": {"score": 4.26, "level_id": 1.2},
	"res://level/world1/level_3.tscn": {"score": 5.56, "level_id": 1.3},
	"res://level/world1/level_4.tscn": {"score": 4.99, "level_id": 1.4},
	"res://level/world1/level_5.tscn": {"score": 5.01, "level_id": 1.5},
	"res://level/world2/level_2_1.tscn": {"score": 1.51, "level_id": 2.1},
	"res://level/world2/level_2_2.tscn": {"score": 4.26, "level_id": 2.2},
	"res://level/world2/level_2_3.tscn": {"score": 5.56, "level_id": 2.3},
	"res://level/world2/level_2_4.tscn": {"score": 4.99, "level_id": 2.4},
	"res://level/world2/level_2_5.tscn": {"score": 5.01, "level_id": 2.5},
	"res://level/world3/level_3_1.tscn": {"score": 1.51, "level_id": 3.1},
	"res://level/world3/level_3_2.tscn": {"score": 4.26, "level_id": 3.2},
	"res://level/world3/level_3_3.tscn": {"score": 5.56, "level_id": 3.3},
	"res://level/world3/level_3_4.tscn": {"score": 4.99, "level_id": 3.4},
	"res://level/world3/level_3_5.tscn": {"score": 5.01, "level_id": 3.5}
}
var scene_path
var current_level_id
var level_data

func _ready():
	info.two_stars = two_stars
	info.three_stars = three_stars
	new_highscore.hide()
	high_score.hide()
	set_lvl_records()
	intro.play()
	fog.visible = false
	light.visible = false
	light_out.visible = false

	if save_Game.time.has(id):
		high_score_time.text = stoppuhr.format_time(save_Game.time[id])

	if save_Game.bonusUnlocked():
		player = 12

	set_cell(1, startPos, player, Vector2i(0, 0), 0)

	if not save_Game.bonusItems.has(id):
		set_cell(1, starPos, 11, Vector2i(0, 0), 0)
	else:
		set_cell(1, starPos, 32, Vector2i(0, 0), 0)

	for tile_pos in get_used_cells(1):
		player_tile_pos = Vector2(tile_pos)
		betreten.append(player_tile_pos)
		break  

func _process(_delta):
	if do_once:
		if str(new_name_edit.text) == "":
			new_name_edit.text = high_score.latest_name
			do_once = false
		
	scene_path = get_tree().current_scene.scene_file_path
	level_data = scores.get(scene_path, {})
	current_level_id = level_data.get("level_id", -1)
	high_score._update_shown_scores(current_level_id)
	light.position = to_global(map_to_local(player_tile_pos))

	if not settings.enabled:
		stoppuhr.process_mode = Node.PROCESS_MODE_ALWAYS
		light_timer.process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event):
	if event.is_action_pressed("right") and not settings.enabled and !info.visible:
		move_player(player_tile_pos + Vector2.RIGHT)
		execute_timeout_actions()
	elif event.is_action_pressed("left") and not settings.enabled and !info.visible:
		move_player(player_tile_pos + Vector2.LEFT)
		execute_timeout_actions()
	elif event.is_action_pressed("up") and not settings.enabled and !info.visible:
		move_player(player_tile_pos + Vector2.UP)
		execute_timeout_actions()
	elif event.is_action_pressed("down") and not settings.enabled and !info.visible:
		move_player(player_tile_pos + Vector2.DOWN)
		execute_timeout_actions()
	elif event.is_action_pressed("reset") and not settings.enabled and !info.visible:  
		restartLevel()
	elif event.is_action_pressed("settings") and !info.visible:  
		if not settings.enabled:
			settings.enabled = true
			stoppuhr.process_mode = Node.PROCESS_MODE_DISABLED
			light_timer.process_mode = Node.PROCESS_MODE_DISABLED
		else:
			settings.enabled = false

func restartLevel():
	if not save_Game.finishedLevels.has(id) and save_Game.bonusItems.has(id):
		save_Game.removeBonus(id)
	get_tree().reload_current_scene()

func move_player(target_tile_pos):
	var target_tile_id = get_cell_source_id(0, target_tile_pos)
	var _tile_data: TileData = get_cell_tile_data(0, player_tile_pos)

	if allowed_tile_ids.has(target_tile_id) and not betreten.has(target_tile_pos):
		erase_cell(1, player_tile_pos)
		set_cell(1, target_tile_pos, player, Vector2i(0, 0), 0)
		add_particle(player_tile_pos)
		player_tile_pos = target_tile_pos

		if target_tile_pos == starPos:
			star_clollected()
			
			stern_player.play()
			bonus = true
			star.texture = load("res://assets/star.png")

		if target_tile_id == 3:
			get_tree().change_scene_to_file("res://level/world1/shortCutLvl.tscn")

		if target_tile_id == 4 or target_tile_id == 37:
			highscore_global = stoppuhr.time
			if not save_Game.finishedLevels.has(id):
				save_Game.levelFinished(id)
				if bonus:
					save_Game.bonusCollected(id)
				save_Game.unlockedLevels.append(id + 1)
				if not save_Game.time.has(id):
					save_Game.time[id] = stoppuhr.time
			else:
				if save_Game.time[id] > stoppuhr.time:
					save_Game.time[id] = stoppuhr.time
				if bonus:
					save_Game.bonusCollected(id)
			if stoppuhr.time < three_stars:
				bewertung.three_stars(id)
			elif stoppuhr.time < two_stars:
				bewertung.two_stars(id)
			else:
				bewertung.one_star(id)
			bewertung.set_times(stoppuhr.time, save_Game.time[id])
			hide_lvl_ui()
			bewertung.bounce_in()
			print(save_Game.collected_stars)

func add_particle(pos: Vector2i):
	var particle = preload("res://level/void.tscn").instantiate()
	particle.global_position = map_to_local(pos)
	particle.z_index = 1
	await get_tree().create_timer(0.5).timeout
	if Vector2i(player_tile_pos.x, player_tile_pos.y) != pos:
		add_child(particle)
		betreten.append(player_tile_pos)

func execute_timeout_actions():
	if not timer_done:
		timer_done = true
		light.visible = true
		fog.visible = true
		light_out.visible = true
		light_out_in.visible = false
		await get_tree().create_timer(0.8).timeout
		light_out.visible = false

func _on_timer_timeout():
	if not timer_done:
		execute_timeout_actions()

func hide_lvl_ui():
	$"../Belichtet/light_out_in".hide()
	$"../Belichtet/gebrauchte_zeit".hide()
	$"../Belichtet/stoppuhr/label".hide()
	$"../Belichtet/Highscore".hide()
	$"../Belichtet/HighScoreTime".hide()
	$"../visual_timer/time".hide()
	$"../Belichtet/Border".hide()
	$"../Belichtet/Star".hide()
	new_highscore.show()
	high_score.show()

func _on_save_highscore_button_pressed(_new_text = ""):
	var new_name = new_name_edit.text.strip_edges()
	if high_score.latest_name != new_name:
		high_score.latest_name = new_name
	high_score.add_entry({"name": high_score.latest_name, "score": (round(highscore_global * 100) / 100), "level_id": current_level_id})
	high_score._save()  # Add this line to save the highscore
	$"../Belichtet/NewHighscore/VBoxContainer/HBoxContainer/SaveHighscoreButton".disabled = true
	
func set_lvl_records():
	if FileAccess.file_exists(high_score.file_name):
		pass
	else:
		for scene_path in scores.keys():
			var temp_level_data = scores[scene_path]
			var temp_lvl_score = temp_level_data["score"]
			var temp_lvl_id = temp_level_data["level_id"]
			high_score.add_entry({"name": "Luviar", "score": temp_lvl_score, "level_id": temp_lvl_id})
			print(temp_lvl_score)
func star_clollected():
	for i in 5:
		star_collected_text.visible = !star_collected_text.visible
		await get_tree().create_timer(0.2).timeout
	star_collected_text.hide()
	

