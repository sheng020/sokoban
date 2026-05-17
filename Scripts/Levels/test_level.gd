extends Node2D

const GRID_W := 12
const GRID_H := 12
const ORIGIN := Vector2(256, -24)
const CELL := 64


func _ready() -> void:
	LevelManager.set_grid_origin(ORIGIN)
	LevelManager.set_grid_size(GRID_W, GRID_H)
	LevelManager.begin_level()

	_add_border_walls()

	var entities := $Entities
	for child in entities.get_children():
		if child.name != "Player" and not child.name.begins_with("SpiritSeed") and not child.name.begins_with("StarBase"):
			continue

	call_deferred("_finalize")


func _add_border_walls() -> void:
	var dummy_node := Node2D.new()
	add_child(dummy_node)

	for x in GRID_W:
		LevelManager.register_entity("wall", Vector2i(x, 0), dummy_node)
		LevelManager.register_entity("wall", Vector2i(x, GRID_H - 1), dummy_node)
	for y in range(1, GRID_H - 1):
		LevelManager.register_entity("wall", Vector2i(0, y), dummy_node)
		LevelManager.register_entity("wall", Vector2i(GRID_W - 1, y), dummy_node)

	_draw_wall_sprites()


func _draw_wall_sprites() -> void:
	var wall_scene := load("res://Scenes/Entities/wall.tscn") as PackedScene
	var wall_positions: Array[Vector2i] = []

	for x in GRID_W:
		wall_positions.append(Vector2i(x, 0))
		wall_positions.append(Vector2i(x, GRID_H - 1))
	for y in range(1, GRID_H - 1):
		wall_positions.append(Vector2i(0, y))
		wall_positions.append(Vector2i(GRID_W - 1, y))

	for wp in wall_positions:
		var wall := wall_scene.instantiate()
		wall.position = ORIGIN + Vector2(wp.x * CELL, wp.y * CELL)
		add_child(wall)

	var floor_tex := load("res://Sprites/Placeholder/floor.png") as Texture2D
	for y in range(1, GRID_H - 1):
		for x in range(1, GRID_W - 1):
			var floor_sprite := Sprite2D.new()
			floor_sprite.texture = floor_tex
			floor_sprite.z_index = -1
			floor_sprite.position = ORIGIN + Vector2(x * CELL, y * CELL)
			add_child(floor_sprite)


func _finalize() -> void:
	LevelManager.finalize_level()
