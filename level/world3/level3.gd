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
@onready var lights_timer = $"../visual_timer/time"
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

@onready var lights_closed = false


func _process(delta):
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
		if event.is_action_pressed("right") and !settings.enabled and !info.visible:
			timeout = true
			move_player(player_tile_pos + Vector2i.RIGHT)
		elif event.is_action_pressed("left") and !settings.enabled and !info.visible:
			timeout = true
			move_player(player_tile_pos + Vector2i.LEFT)	
		elif event.is_action_pressed("up") and !settings.enabled and !info.visible:
			timeout = true
			move_player(player_tile_pos + Vector2i.UP)
		elif event.is_action_pressed("down") and !settings.enabled and !info.visible:
			timeout = true
			move_player(player_tile_pos + Vector2i.DOWN)
		elif event.is_action_pressed("reset") and !settings.enabled and !info.visible:  
			restartLevel()
		elif event.is_action_pressed("settings") and !info.visible:  
			if settings.enabled == false:
				settings.enabled = true
				stoppuhr.process_mode = Node.PROCESS_MODE_DISABLED
			elif settings.enabled:
				settings.enabled = false
				stoppuhr.process_mode = Node.PROCESS_MODE_ALWAYS

func move_player(target_tile_pos):
	
	# Infos 端ber das Target Tile bekommen
	var target_tile_id = get_cell_source_id(0, target_tile_pos)
	var _tile_data: TileData = get_cell_tile_data(0,player_tile_pos)

	# Wenn wir das Teil betreten duerfen, dann bewegen
	if (allowed_tile_ids.has(target_tile_id)) and !betreten.has(target_tile_pos) and !laser.has(target_tile_pos):
		erase_cell(1,player_tile_pos)
		
		if (portalsA.has(target_tile_pos) or portalsB.has(target_tile_pos)) and !benutzte_portale.has(target_tile_pos):
			target_tile_pos = use_portal(target_tile_pos)
	
		set_cell(1, target_tile_pos, player, Vector2i(0,0),0)
		player_tile_pos = target_tile_pos
	
	# Boden fuellen 
	if buttons.has(target_tile_pos) and !used_buttons.has(target_tile_pos):
		Klicker.play()
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
		hide_lvl_ui()

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
	$"../Belichtet/light_out_in".hide()
	await get_tree().create_timer(0.8).timeout
	$"../Belichtet/light_out".visible = false
	lights_timer.hide()
func _on_timer_timeout():
	timeout = true
	
