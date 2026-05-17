extends StaticBody2D

var _sprite: Sprite2D


func _ready() -> void:
	_sprite = $Sprite
	var grid_pos := LevelManager.world_to_grid(position)
	LevelManager.register_entity("spirit_seed", grid_pos, self)
	position = LevelManager.grid_to_world(grid_pos)


func set_matched(is_on_base: bool) -> void:
	if _sprite:
		_sprite.modulate = Color(1.2, 1.5, 1.0) if is_on_base else Color.WHITE
