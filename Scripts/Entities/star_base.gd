extends StaticBody2D

var _sprite: Sprite2D


func _ready() -> void:
	_sprite = $Sprite
	var grid_pos := LevelManager.world_to_grid(position)
	LevelManager.register_entity("star_base", grid_pos, self)
	position = LevelManager.grid_to_world(grid_pos)


func set_occupied(is_occupied: bool) -> void:
	if _sprite:
		_sprite.modulate = Color(1.0, 1.3, 0.6) if is_occupied else Color.WHITE
