extends CharacterBody2D

func _ready() -> void:
	var grid_pos := LevelManager.world_to_grid(position)
	LevelManager.register_entity("player", grid_pos, self)
	position = LevelManager.grid_to_world(grid_pos)


func _unhandled_input(event: InputEvent) -> void:
	var direction := Vector2i.ZERO
	if event.is_action_pressed("move_up"):
		direction = Vector2i.UP
	elif event.is_action_pressed("move_down"):
		direction = Vector2i.DOWN
	elif event.is_action_pressed("move_left"):
		direction = Vector2i.LEFT
	elif event.is_action_pressed("move_right"):
		direction = Vector2i.RIGHT
	elif event.is_action_pressed("undo"):
		LevelManager.undo()
		return
	elif event.is_action_pressed("reset"):
		LevelManager.reset_level()
		return
	else:
		return

	if direction != Vector2i.ZERO:
		LevelManager.request_move(direction)
