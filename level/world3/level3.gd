extends TileMap

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

func move_player(pos : Vector2i):
