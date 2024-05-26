extends TileMap
@onready var light = $"../Light"
@onready var light_out = $"../Belichtet/light_out"
@onready var light_out_in = $"../Belichtet/light_out_in"
@onready var light_timer = $"../visual_timer/Timer"
@onready var settings = $"../Belichtet/Settings"

var tile_size = 32
var allowed_tile_ids = [2,3,4,8,9]  # ID der Tiles, auf denen sich der Spieler bewegen darf
var player_tile_pos  # Aktuelle Tile-Position des Spielers (Vector2)
var timer_done = false
var early_start = false
@onready var bonus = false 
@onready var betreten: Array = []
@onready var fog = $"../Fog"
@onready var star = $"../Belichtet/Star"
@onready var save_Game = preload("res://save/saveGame.tres")
@onready var player = 1



@export var id : int
@export var starPos : Vector2
@export var startPos : Vector2i

@onready var stoppuhr = $"../Belichtet/stoppuhr"
@onready var high_score_time = $"../Belichtet/HighScoreTime"



func _ready():
	fog.visible = false
	light.visible = false
	light_out.visible = false
	
	if save_Game.time[id]:
		high_score_time.text = stoppuhr.format_time(save_Game.time[id])

	
	if save_Game.bonusUnlocked(): #Ändern!!!
		player = 12
	
	set_cell(1, startPos, player, Vector2i(0,0),0)
	
	if !save_Game.bonusItems.has(id):
		set_cell(1, starPos, 11, Vector2i(0,0), 0)
	else: 
		star.texture = load("res://assets/star.png")
	# Find the Tile-Position of the Player on Layer 1
	for tile_pos in get_used_cells(1):
		player_tile_pos = Vector2(tile_pos)
		betreten.append(player_tile_pos)
		break  # Take the first found Tile as starting position

func _process(_delta):
	light.position = to_global(map_to_local(player_tile_pos))
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
		elif event.is_action_pressed("reset"):  # New functionality for reset button
			restartLevel()
		elif event.is_action_pressed("settings"):  # New functionality for reset button
			if settings.enabled == false:
				settings.enabled = true
				stoppuhr.process_mode = Node.PROCESS_MODE_DISABLED
				light_timer.process_mode = Node.PROCESS_MODE_DISABLED
			elif settings.enabled:
				settings.enabled = false


func restartLevel():
	if !save_Game.finishedLevels.has(id) and save_Game.bonusItems.has(id):
		save_Game.removeBonus(id)
	get_tree().reload_current_scene()

func move_player(target_tile_pos):
	var target_tile_id = get_cell_source_id(0, target_tile_pos)
	var _tile_data: TileData = get_cell_tile_data(0,player_tile_pos)

	if (allowed_tile_ids.has(target_tile_id)) and !betreten.has(target_tile_pos):
		erase_cell(1,player_tile_pos)
			# Set the Player at the new position
		set_cell(1, target_tile_pos, player, Vector2i(0,0),0)
		add_particle(player_tile_pos)
		player_tile_pos = target_tile_pos

		
		if target_tile_pos == starPos:
			bonus = true
			star.texture = load("res://assets/star.png")
		
		# When the player enters the vent
		if target_tile_id == 3:
			get_tree().change_scene_to_file("res://level/shortCutLvl.tscn")
		
		# When the player reaches the goal 
		if target_tile_id == 4 or target_tile_id == 10:
			if !save_Game.finishedLevels.has(id):
				save_Game.levelFinished(id)
				if bonus: 
					save_Game.bonusCollected(id)
				save_Game.unlockedLevels.append(id+1)
				if !save_Game.time[id]:
					save_Game.time[id] = stoppuhr.time
			else:
				if save_Game.time[id] > stoppuhr.time:
					save_Game.time[id] = stoppuhr.time
				if bonus: 
					save_Game.bonusCollected(id)
			
			get_tree().change_scene_to_file("res://main-menu/lvlSelect.tscn")

func add_particle(pos: Vector2i):
	var particle = preload("res://level/void.tscn").instantiate()
	particle.global_position = map_to_local(pos)
	particle.z_index = 1
	await get_tree().create_timer(1).timeout
	if Vector2i(player_tile_pos.x, player_tile_pos.y) != pos:
		add_child(particle)
		#await get_tree().create_timer(3.0).timeout
		betreten.append(player_tile_pos)

func execute_timeout_actions():
	if !timer_done:
		timer_done = true
		light.visible = true
		fog.visible = true
		light_out.visible = true
		light_out_in.visible = false
		await get_tree().create_timer(0.8).timeout
		light_out.visible = false
	
	
func _on_timer_timeout():
	if !timer_done:	execute_timeout_actions()
