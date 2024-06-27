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

@onready var star = $"../Star"
@onready var intro = $"../Intro"
@onready var bewertung = $"../Bewertung"
@onready var settings = $"../Settings"

@onready var player_tile_pos : Vector2i = startPos
@onready var allowed_tile_ids = [1, 10, 19, 31]
@onready var betreten: Array = []
@onready var benutzte_portale = []
@onready var save_Game = preload("res://save/saveGame.tres")
@onready var player = save_Game.getWorld3Player()
@onready var used_buttons = []


func _ready():
	intro.play()
	set_cell(1, startPos, player, Vector2i(0,0),0)
	setup_connectors()
	
	# Falls der Stern noch nicht eingesammelt wurde einen Stern spawnen
	if !save_Game.bonusItems.has(id):
		set_cell(1, starPos, 36, Vector2i(0,0), 0)
	else: 
		set_cell(1, starPos, 32, Vector2i(0,0), 0)


func _unhandled_input(event):
		if event.is_action_pressed("right"):
			move_player(player_tile_pos + Vector2i.RIGHT)
		elif event.is_action_pressed("left"):
			move_player(player_tile_pos + Vector2i.LEFT)	
		elif event.is_action_pressed("up"):
			move_player(player_tile_pos + Vector2i.UP)
		elif event.is_action_pressed("down"):
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
	
	# Infos über das Target Tile bekommen
	var target_tile_id = get_cell_source_id(0, target_tile_pos)
	var _tile_data: TileData = get_cell_tile_data(0,player_tile_pos)
	print(target_tile_pos, starPos)

	# Wenn wir das Teil betreten dürfen, dann bewegen
	if (allowed_tile_ids.has(target_tile_id)) and !betreten.has(target_tile_pos) and !laser.has(target_tile_pos):
		erase_cell(1,player_tile_pos)
		
		if (portalsA.has(target_tile_pos) or portalsB.has(target_tile_pos)) and !benutzte_portale.has(target_tile_pos):
			target_tile_pos = use_portal(target_tile_pos)
	
		set_cell(1, target_tile_pos, player, Vector2i(0,0),0)
		player_tile_pos = target_tile_pos
	
	# Boden füllen lol
	if buttons.has(target_tile_pos) and !used_buttons.has(target_tile_pos):
		erase_cell(1, laser.pop_front())
		used_buttons.append(target_tile_pos)
		erase_cell(1, target_tile_pos)
		set_cell(1, target_tile_pos, 35, Vector2i(0,0),0)
	
	if str(target_tile_pos) == str(starPos):
		if !save_Game.bonusItems.has(id):
			save_Game.bonusCollected(id)
			star.texture = preload("res://assets/buttons/gray/stargray.png")
		
	if target_tile_id == 31:
			if !save_Game.finishedLevels.has(id):
				save_Game.levelFinished(id)	
				save_Game.unlockedLevels.append(id+1)
			bewertung.bounce_in()
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

# Benutzt das Portal und sorgt dafür, dass es nicht ein zweites mal benutzt werden kann.
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
 


