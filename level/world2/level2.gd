extends TileMap
@onready var light = $"../Light"
@onready var light_out_in = $"../Belichtet/light_out_in"
@onready var light_timer = $"../Belichtet/visual_timer/Timer"
@onready var settings = $"../Belichtet/Settings"

var astagrid = AStarGrid2D.new()
const is_solid = "is_solid"
var tile_size = 32
var allowed_tile_ids = [5,7, 23]  # ID der Tiles, auf denen sich der Spieler bewegen darf
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
var move_in_two = false
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
	
	# Damit sich die gegner bewegen können
	randomize()
	execute_timeout_actions()
	# Falls ein Highscore besteht, anzeigen
	if save_Game.time[id]:
		high_score_time.text = stoppuhr.format_time(save_Game.time[id])

	# Belohnung für die 5 gesammelten Sterne
	if save_Game.bonusUnlocked():
		player = 12
	
	
	# Falls der Stern noch nicht eingesammelt wurde einen Stern spawnen
	if !save_Game.bonusItems.has(id):
		set_cell(1, starPos, 11, Vector2i(0,0), 0)
		star.texture = load("res://assets/buttons/gray/stargray.png")
	else: 
		star.texture = load("res://assets/buttons/orange/starorgange.png")
	setup_grid()
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
			
	while(true): #Monster Animation laufen lassen
		monster_animation()
		await get_tree().create_timer(0.8).timeout

func _process(_delta):
	if not fog_red:
		fade_fog()
	# Licht soll Spieler verfolgen
	light.position = to_global(map_to_local(player_tile_pos))
	
	

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
			elif settings.enabled:
				settings.enabled = false
				stoppuhr.process_mode = Node.PROCESS_MODE_ALWAYS
		


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
		for enemy in enemy_ids:
			if get_cell_source_id(1,target_tile_pos) == enemy:
				player_tile_pos = target_tile_pos
				move_in_two = false
				
		set_cell(1, target_tile_pos, player, Vector2i(0,0),0)
		player_tile_pos = target_tile_pos

		# Monster bewegen sich jeden 2ten schritt den der spieler macht
		if move_in_two:
			move_monster_towards_player()
			move_in_two = false
		elif not move_in_two:
			move_in_two = true
			
		# Stern einsammeln
		if target_tile_pos == starPos:
			bonus = true
			star.texture = load("res://assets/buttons/orange/starorgange.png")
		
		# Wenn das Ziel erreicht wird die ganzen Infos im SaveGame speichern 
		if target_tile_id == 5:
			if !save_Game.finishedLevels.has(id):
				save_Game.levelFinished(id)
				if bonus: 
					save_Game.bonusCollected(id)
					print(save_Game.bonusItems)
					
				# Nächstes Level im Menü freischalten
				save_Game.unlockedLevels.append(id+1)
				if !save_Game.time[id]:
					save_Game.time[id] = stoppuhr.time
			
			
			get_tree().change_scene_to_file("res://main-menu/level_selector.tscn")

# Licht ausschalten
func execute_timeout_actions():
	if !timer_done:
		timer_done = true
		light.visible = true
		fog.visible = true
		await get_tree().create_timer(0.8).timeout
	
func _on_timer_timeout():
	if !timer_done: 
		execute_timeout_actions()
	
func fade_fog():
	var i = 0
	var j = 1
	fog_red = true
	while i < 0.8:
		fog.color = Color(i,0,0,1)
		i = i+0.01
		await get_tree().create_timer(0.01).timeout
		
	while j > 0:
		fog.color = Color(j,0,0,1)
		j = j-0.01
		await get_tree().create_timer(0.01).timeout
	# Monster bewegt sich um eins wenn es dunkel ist
	move_monster_towards_player()
	await get_tree().create_timer(1.8).timeout
	fog_red = false
	
#Animation der Monster
func monster_animation():
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
			var path_taken = astagrid.get_id_path(enemy_positions[i], player_tile_pos)
			if get_cell_source_id(1,path_taken[1]) == -1 or player:
				erase_cell(1, enemy_positions[i])
				set_cell(1, path_taken[1], enemy_ids[i], Vector2i(0,0), 0)
				enemy_positions[i] = path_taken[1]
				# Wenn vom Monster gefressen, dann Game Over	
				if path_taken[1] == Vector2i(player_tile_pos):
					await get_tree().create_timer(0.5).timeout
					hide_lvl_ui()
					$"../Belichtet/GameOver".bounce_in()
					

func setup_grid():
	astagrid.region = Rect2i(0,0,100,100)
	astagrid.cell_size = Vector2i(32,32)
	astagrid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astagrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astagrid.update()
	for cell in get_used_cells(0):
		astagrid.set_point_solid(cell, is_spot_solid(cell))

#func show_path(start: Vector2i, end: Vector2i):
#	var path_taken = astagrid.get_id_path(start, end)
#	for cell in path_taken:
#		# Stern zum testen
#		set_cell(1, cell, 11, Vector2i(0,0),0)

func is_spot_solid(spot_to_check: Vector2i) -> bool:
	return get_cell_tile_data(0, spot_to_check).get_custom_data(is_solid)

func hide_lvl_ui():
	$"../Belichtet/light_out_in".hide()
	$"../Belichtet/gebrauchte_zeit".hide()
	$"../Belichtet/stoppuhr/label".hide()
	$"../Belichtet/Highscore".hide()
	$"../Belichtet/HighScoreTime".hide()
	$"../Belichtet/Border".hide()
	$"../Belichtet/Star".hide()
	$"../Belichtet/HighScoreTime".hide()
