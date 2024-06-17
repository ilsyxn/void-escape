extends TileMap
@onready var light = $"../Light"
@onready var light_out_in = $"../Belichtet/light_out_in"
@onready var light_timer = $"../Belichtet/visual_timer/Timer"
@onready var settings = $"../Belichtet/Settings"

var tile_size = 32
var allowed_tile_ids = [5,7]  # ID der Tiles, auf denen sich der Spieler bewegen darf
var player_tile_pos  # Aktuelle Tile-Position des Spielers (Vector2)
var enemy_positions = [enemy01_tile_pos, enemy02_tile_pos, enemy03_tile_pos, enemy04_tile_pos]
var enemy_ids = [enemy1_id, enemy2_id, enemy3_id, enemy4_id]
var enemy01_tile_pos
var enemy02_tile_pos
var enemy03_tile_pos
var enemy04_tile_pos
var enemy1_id
var enemy2_id
var enemy3_id
var enemy4_id
var timer_done = false
var early_start = false
var fog_red = false
@onready var bonus = false 
@onready var betreten: Array = []
@onready var fog = $"../Fog"
@onready var star = $"../Belichtet/Star"
@onready var save_Game = preload("res://save/saveGame.tres")
@onready var player = 1
@onready var particles = 0

@export var id : int
@export var starPos : Vector2
@export var startPos : Vector2i

@onready var stoppuhr = $"../Belichtet/stoppuhr"
@onready var high_score_time = $"../Belichtet/HighScoreTime"

func _ready():
	randomize()

	# Falls ein Highscore besteht, anzeigen
	if save_Game.time[id]:
		high_score_time.text = stoppuhr.format_time(save_Game.time[id])

	# Belohnung für die 5 gesammelten Sterne
	if save_Game.bonusUnlocked():
		player = 12
	
	
	# Falls der Stern noch nicht eingesammelt wurde einen Stern spawnen
	if !save_Game.bonusItems.has(id):
		set_cell(1, starPos, 11, Vector2i(0,0), 0)
	else: 
		star.texture = load("res://assets/star.png")
	
# Player Position auf der Map finden
	for tile_pos in get_used_cells(1):
		if get_cell_source_id(1, tile_pos) == 1 :
			player_tile_pos = Vector2(tile_pos)
		# Enemy 1 Position auf der Map finden
		elif get_cell_source_id(1, tile_pos) == 13 :
			enemy01_tile_pos = Vector2(tile_pos)
			enemy1_id = 13
		# Enemy 2 Position auf der Map finden
		elif get_cell_source_id(1, tile_pos) == 14 :
			enemy02_tile_pos = Vector2(tile_pos)
			enemy2_id = 14
		# Enemy 3 Position auf der Map finden
		elif get_cell_source_id(1, tile_pos) == 15 :
			enemy03_tile_pos = Vector2(tile_pos)
			enemy3_id = 15
		# Enemy 4 Position auf der Map finden
		elif get_cell_source_id(1, tile_pos) == 16 :
			enemy04_tile_pos = Vector2(tile_pos)
			enemy4_id = 16

	enemy_positions = [enemy01_tile_pos, enemy02_tile_pos, enemy03_tile_pos, enemy04_tile_pos]
	enemy_ids = [enemy1_id, enemy2_id, enemy3_id, enemy4_id]
			
#	for i in range(100):
#		change_monster()
#		await get_tree().create_timer(0.8).timeout
			
	
		

func _process(_delta):
	if not fog_red:
		fade_fog()
	# Licht soll Spieler verfolgen
	light.position = to_global(map_to_local(player_tile_pos))
	
	# Timer wieder aktivieren wenn Pausemenü geschlossen wird
	if settings.enabled == false:
		stoppuhr.process_mode = Node.PROCESS_MODE_ALWAYS
		light_timer.process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event):
		if event.is_action_pressed("right"):
			move_player(player_tile_pos + Vector2.RIGHT)
			execute_timeout_actions()
		elif event.is_action_pressed("left"):
			move_player(player_tile_pos + Vector2.LEFT)
			execute_timeout_actions()
		elif event.is_action_pressed("up"):
			move_player(player_tile_pos + Vector2.UP)
			execute_timeout_actions()
		elif event.is_action_pressed("down"):
			move_player(player_tile_pos + Vector2.DOWN)
			execute_timeout_actions()
		elif event.is_action_pressed("reset"):  
			restartLevel()
		elif event.is_action_pressed("settings"):  
			if settings.enabled == false:
				settings.enabled = true
				stoppuhr.process_mode = Node.PROCESS_MODE_DISABLED
				light_timer.process_mode = Node.PROCESS_MODE_DISABLED
			elif settings.enabled:
				settings.enabled = false
		


func restartLevel():
	# Bonus soll nach dem reset nicht gespeichert bleiben
	if !save_Game.finishedLevels.has(id) and save_Game.bonusItems.has(id):
		save_Game.removeBonus(id)
	get_tree().reload_current_scene()

func move_player(target_tile_pos):
	
	# Infos über das Target Tile bekommen
	var target_tile_id = get_cell_source_id(0, target_tile_pos)
	var _tile_data: TileData = get_cell_tile_data(0,player_tile_pos)

	# Wenn wir das Teil betreten dürfen, dann bewegen
	if (allowed_tile_ids.has(target_tile_id)) and !betreten.has(target_tile_pos):
		erase_cell(1,player_tile_pos)
			# Set the Player at the new position
		set_cell(1, target_tile_pos, player, Vector2i(0,0),0)
		player_tile_pos = target_tile_pos
		move_monster_towards_player()

		# Stern einsammeln
		if target_tile_pos == starPos:
			bonus = true
			star.texture = load("res://assets/star.png")
		
		# Secret Level
		if target_tile_id == 3:
			get_tree().change_scene_to_file("res://level/world1/shortCutLvl.tscn")
		
		# Wenn das Ziel erreicht wird die ganzen Infos im SaveGame speichern 
		if target_tile_id == 5:
			if !save_Game.finishedLevels.has(id):
				save_Game.levelFinished(id)
				if bonus: 
					save_Game.bonusCollected(id)
					
				# Nächstes Level im Menü freischalten
				save_Game.unlockedLevels.append(id+1)
				if !save_Game.time[id]:
					save_Game.time[id] = stoppuhr.time
			else:
				# Falls wir einen neuen Highscore haben
				if save_Game.time[id] > stoppuhr.time:
					save_Game.time[id] = stoppuhr.time
				if bonus: 
					save_Game.bonusCollected(id)
			
			get_tree().change_scene_to_file("res://main-menu/world1.tscn")

# Licht ausschalten
func execute_timeout_actions():
	if !timer_done:
		timer_done = true
		light.visible = true
		fog.visible = true
		light_out_in.visible = false
		await get_tree().create_timer(0.8).timeout
	
	
func _on_timer_timeout():
	if !timer_done:	execute_timeout_actions()
	
func fade_fog():
	var i = 0
	var j = 1
	fog_red = true
	while i < 1:
		fog.color = Color(i,0,0,1)
		i = i+0.01
		await get_tree().create_timer(0.01).timeout
		
	while j > 0:
		fog.color = Color(j,0,0,1)
		j = j-0.01
		await get_tree().create_timer(0.01).timeout
		
	await get_tree().create_timer(2.0).timeout
	fog_red = false
	
#Animation
func change_monster():
	for i in range(4):
		if enemy_positions[i] != null:
			var enemy_id = get_cell_source_id(1, enemy_positions[i])
			if enemy_id == 14:
				enemy_ids[i] = 15
			elif enemy_id == 15:
				enemy_ids[i] = 13
			elif enemy_id == 13:
				enemy_ids[i] = 16
			else:
				enemy_ids[i] = 14
			set_cell(1, enemy_positions[i], enemy_ids[i], Vector2i(0,0),0)
			
func move_monster_towards_player():
	for i in range(4):
		if enemy_positions[i] != null:
			var direction_to_player = player_tile_pos - enemy_positions[i]
			var target_tile_pos

			# Entscheiden, ob sich das Monster horizontal oder vertikal bewegen soll
			if abs(direction_to_player.x) > abs(direction_to_player.y):
				# Bewegen Sie sich horizontal in Richtung des Spielers
				target_tile_pos = enemy_positions[i] + Vector2(sign(direction_to_player.x), 0)
			else:
				# Bewegen Sie sich vertikal in Richtung des Spielers
				target_tile_pos = enemy_positions[i] + Vector2(0, sign(direction_to_player.y))

			var target_tile_id = get_cell_source_id(0, target_tile_pos)

			# Überprüfen Sie, ob das Ziel-Tile erlaubt ist
			if allowed_tile_ids.has(target_tile_id):
				erase_cell(1, enemy_positions[i])
				set_cell(1, target_tile_pos, enemy_ids[i], Vector2i(0,0),0)
				enemy_positions[i] = target_tile_pos



