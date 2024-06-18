extends TileMap


@export var id : int
@export var starPos : Vector2
@export var startPos : Vector2i
@export var portals : Array[Vector2i]
@export var connectors : Array[Vector2i]
@export var spaces : Array[Vector2i]

@onready var portal_nodesA = [$"../Portal"]
@onready var portal_nodesB = [$"../Portal2"]

@onready var player_tile_pos : Vector2i = startPos
@onready var allowed_tile_ids = [1, 10]
@onready var betreten: Array = []
@onready var benutzte_portale = []
@onready var save_Game = preload("res://save/saveGame.tres")
@onready var player = save_Game.getWorld3Player()
func _ready():
	set_cell(1, startPos, player, Vector2i(0,0),0)


func _unhandled_input(event):
		if event.is_action_pressed("right"):
			move_player(player_tile_pos + Vector2i.RIGHT)
		elif event.is_action_pressed("left"):
			move_player(player_tile_pos + Vector2i.LEFT)	
		elif event.is_action_pressed("up"):
			move_player(player_tile_pos + Vector2i.UP)
		elif event.is_action_pressed("down"):
			move_player(player_tile_pos + Vector2i.DOWN)

func move_player(target_tile_pos):
	
	# Infos über das Target Tile bekommen
	var target_tile_id = get_cell_source_id(0, target_tile_pos)
	var _tile_data: TileData = get_cell_tile_data(0,player_tile_pos)
	print(target_tile_id)

	# Wenn wir das Teil betreten dürfen, dann bewegen
	if (allowed_tile_ids.has(target_tile_id)) and !betreten.has(target_tile_pos) and !spaces.has(target_tile_pos):
		erase_cell(1,player_tile_pos)
		
		for i in portals.size():
			if target_tile_pos == portals[i] and !benutzte_portale.has(target_tile_pos):
				var port_pos = target_tile_pos
				target_tile_pos = connectors[i]
				remove_portals(port_pos, target_tile_pos)
				break
	
		set_cell(1, target_tile_pos, player, Vector2i(0,0),0)
		player_tile_pos = target_tile_pos
	
	# Boden füllen lol
	if target_tile_id == 12:
		erase_cell(1, spaces.pop_front())


		
	if target_tile_id == 10:
			if !save_Game.finishedLevels.has(id):
				save_Game.levelFinished(id)	
			get_tree().change_scene_to_file("res://main-menu/level_selector.tscn")

func remove_portals(portal_pos, connector_pos):
	# Portal aus dem Level nehmen, wenn es benutzt wurde
	for i in portal_nodesA.size():
		if !benutzte_portale.has(portal_pos) and !benutzte_portale.has(connector_pos):
			if portal_nodesA[i].map_position == portal_pos or portal_nodesB[i].map_position == portal_pos:
				portal_nodesA[i].free()
				portal_nodesB[i].free()
	# Merken, dass das Portal benutzt wurde
	benutzte_portale.append(portal_pos)
	benutzte_portale.append(connector_pos)

