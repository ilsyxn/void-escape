extends TileMap

@export var id : int
@export var starPos : Vector2
@export var startPos : Vector2i
@export var portalsA : Array[Vector2i]
@export var portalsB : Array[Vector2i]
@export var laser : Array[Vector2i]
@export var portal_nodesA : Array[Node2D]
@export var portal_nodesB : Array[Node2D]
@export var buttons : Array [Vector2i]
@export var three_stars: float
@export var two_stars: float
@onready var bewertung = $"../Belichtet/Bewertung"
@onready var bonus = false
@onready var stoppuhr = $"../Belichtet/stoppuhr"
@onready var light_out = $Belichtet/light_out

@onready var star = $"../Belichtet/Star"
@onready var intro = $"../Intro"
@onready var fog = $"../Fog"

@onready var settings = $"../Belichtet/Settings"
@onready var fog_active = false
@onready var stern_player = $"../SternPlayer"
@onready var star_collected_text = $"../Belichtet/star_collected"
@onready var player_tile_pos : Vector2i = startPos
@onready var allowed_tile_ids = [1, 10, 19, 31]
@onready var betreten: Array = []
@onready var benutzte_portale = []
@onready var save_Game = preload("res://save/saveGame.tres")
@onready var player = save_Game.getWorld3Player()
@onready var used_buttons = []
@onready var info = $"../Belichtet/Info"
@onready var highscore = $"../Belichtet/Highscore"
@onready var high_score_time = $"../Belichtet/HighScoreTime"
@onready var light = $"../Light"
@onready var timeout = false
@onready var new_highscore = $"../Belichtet/NewHighscore"
@onready var new_name_edit = $"../Belichtet/NewHighscore/VBoxContainer/HBoxContainer/NewNameEdit"
@onready var high_score = $"../Belichtet/Highscore2"
@onready var onscreen_keyboard = $"../Belichtet/OnscreenKeyboard"
@onready var lights_closed = false

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

func _process(delta):
	if do_once:
		if str(new_name_edit.text) == "":
			new_name_edit.text = high_score.latest_name
			do_once = false
	light.position = to_global(map_to_local(player_tile_pos))
	if fog_active and !light.texture_scale > 1.5:
		var tween = create_tween()
		tween.tween_property(light, "texture_scale", 1.5, 1.5)
	elif !fog_active and !light.texture_scale < 0.5:
		var tween = create_tween()
		tween.tween_property(light, "texture_scale", 0.5, 1.5)
	if timeout and !lights_closed:
		toggle_light()
		
	
func _ready():
	info.two_stars = two_stars
	info.three_stars = three_stars
	new_highscore.hide()
	high_score.hide()
	set_lvl_records()
	IntroPlayer.play()
	set_cell(1, startPos, player, Vector2i(0,0),0)
	setup_connectors()
	if save_Game.time[id]:
		high_score_time.text = stoppuhr.format_time(save_Game.time[id])
	# Falls der Stern noch nicht eingesammelt wurde einen Stern spawnen
	if !save_Game.bonusItems.has(id):
		set_cell(1, starPos, 36, Vector2i(0,0), 0)
	else: 
		set_cell(1, starPos, 32, Vector2i(0,0), 0)


func _unhandled_input(event):
		if event is InputEventKey:
			onscreen_keyboard.autoShow = false
		elif event is InputEventJoypadButton:
			onscreen_keyboard.autoShow = true
		if event.is_action_pressed("right"):
			timeout = true
			move_player(player_tile_pos + Vector2i.RIGHT)
		elif event.is_action_pressed("left"):
			timeout = true
			move_player(player_tile_pos + Vector2i.LEFT)	
		elif event.is_action_pressed("up"):
			timeout = true
			move_player(player_tile_pos + Vector2i.UP)
		elif event.is_action_pressed("down"):
			timeout = true
			move_player(player_tile_pos + Vector2i.DOWN)
		elif event.is_action_pressed("reset"):  
			restartLevel()
		elif event.is_action_pressed("settings"):  
			if settings.enabled == false:
				settings.enabled = true
				# stoppuhr.process_mode = Node.PROCESS_MODE_DISABLED
				# light_timer.process_mode = Node.PROCESS_MODE_DISABLED
			elif settings.enabled:
				settings.enabled = false

func move_player(target_tile_pos):
	
	# Infos 端ber das Target Tile bekommen
	var target_tile_id = get_cell_source_id(0, target_tile_pos)
	var _tile_data: TileData = get_cell_tile_data(0,player_tile_pos)
	print(target_tile_pos, starPos)

	# Wenn wir das Teil betreten duerfen, dann bewegen
	if (allowed_tile_ids.has(target_tile_id)) and !betreten.has(target_tile_pos) and !laser.has(target_tile_pos):
		erase_cell(1,player_tile_pos)
		
		if (portalsA.has(target_tile_pos) or portalsB.has(target_tile_pos)) and !benutzte_portale.has(target_tile_pos):
			target_tile_pos = use_portal(target_tile_pos)
	
		set_cell(1, target_tile_pos, player, Vector2i(0,0),0)
		player_tile_pos = target_tile_pos
	
	# Boden fuellen 
	if buttons.has(target_tile_pos) and !used_buttons.has(target_tile_pos):
		erase_cell(1, laser.pop_front())
		used_buttons.append(target_tile_pos)
		erase_cell(1, target_tile_pos)
		set_cell(1, target_tile_pos, 35, Vector2i(0,0),0)
	
	if str(target_tile_pos) == str(starPos):
		if !save_Game.bonusItems.has(id):
			save_Game.bonusCollected(id)
			if !bonus:
				SternPlayer.play()
				star_clollected()
			bonus = true
			star.texture = preload("res://assets/buttons/gray/stargray.png")
		
	if target_tile_id == 31:
		if not save_Game.time.has(id):
			save_Game.time[id] = stoppuhr.time
		if save_Game.time.has(id):
			if save_Game.time[id] > stoppuhr.time:
				save_Game.time[id] = stoppuhr.time
		stoppuhr.active = false
		if !save_Game.finishedLevels.has(id):
			save_Game.levelFinished(id)	
			save_Game.unlockedLevels.append(id+1)
		if stoppuhr.time < three_stars:
			bewertung.three_stars(id)
		elif stoppuhr.time < two_stars:
			bewertung.two_stars(id)
		else:
			bewertung.one_star(id)
			bewertung.set_times(stoppuhr.time, save_Game.time[id])
			#hide_lvl_ui()
		bewertung.set_times(stoppuhr.time,save_Game.time[id])
		bewertung.bounce_in()
		print(save_Game.collected_stars)

# Benutzt das Portal und sorgt daf端r, dass es nicht ein zweites mal benutzt werden kann.
func use_portal(coord : Vector2i):
	if portalsA.has(coord):
		for i in portalsA.size():
			if portalsA[i] == coord:
				benutzte_portale.append(portalsA[i])
				benutzte_portale.append(portalsB[i])
				portal_nodesA[i].free()
				portal_nodesB[i].free()
				return portalsB[i]
	elif portalsB.has(coord):
		for i in portalsB.size():
			if portalsB[i] == coord:
				benutzte_portale.append(portalsA[i])
				benutzte_portale.append(portalsB[i])
				portal_nodesA[i].free()
				portal_nodesB[i].free()
				return portalsA[i]

func setup_connectors():
	for i in portal_nodesA.size():
		if portal_nodesB[i]:
			portal_nodesB[i].farbe = portal_nodesA[i].farbe
		
func restartLevel():
	# Bonus soll nach dem reset nicht gespeichert bleiben
	if !save_Game.finishedLevels.has(id) and save_Game.bonusItems.has(id):
		save_Game.removeBonus(id)
	get_tree().reload_current_scene()


func hide_lvl_ui():
	$"../Belichtet/light_out_in".hide()
	$"../Belichtet/gebrauchte_zeit".hide()
	$"../Belichtet/stoppuhr/label".hide()
	$"../Belichtet/Highscore".hide()
	$"../Belichtet/HighScoreTime".hide()
	$"../visual_timer/time".hide()
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
	onscreen_keyboard.hide()
	
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
 
func _on_light_timer_timeout():
	fog_active = !fog_active

func star_clollected():
	for i in 5:
		star_collected_text.visible = !star_collected_text.visible
		await get_tree().create_timer(0.2).timeout
	star_collected_text.hide()

func toggle_light():
	lights_closed = true
	fog.visible = true
	light.visible = true
	$"../Belichtet/light_out".visible = true
	$"../Belichtet/light_out_in".visible = false
	await get_tree().create_timer(0.8).timeout
	$"../Belichtet/light_out".visible = false

func _on_timer_timeout():
	timeout = true
	
