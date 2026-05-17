extends Node2D

@export var grid_origin := Vector2(256, -24)
@export var grid_width := 12
@export var grid_height := 12


func _ready() -> void:
	LevelManager.set_grid_origin(grid_origin)
	LevelManager.set_grid_size(grid_width, grid_height)
	LevelManager.begin_level()

	_register_walls()

	call_deferred("_finalize")


func _register_walls() -> void:
	var wall_layer := get_node_or_null("WallLayer")
	if wall_layer and wall_layer is TileMapLayer:
		for cell in wall_layer.get_used_cells():
			LevelManager.register_entity("wall", cell, wall_layer)


func _finalize() -> void:
	LevelManager.finalize_level()
