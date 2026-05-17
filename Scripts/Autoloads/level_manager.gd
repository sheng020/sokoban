extends Node

signal level_completed
signal level_ready
signal move_count_changed(count: int)

const CELL_SIZE := 64
const MOVE_DURATION := 0.1

var _grid_origin := Vector2(256, -24)
var _player_pos: Vector2i
var _player_node: Node2D
var _seeds: Array[Dictionary] = []
var _bases: Array[Dictionary] = []
var _walls: Array[Vector2i] = []
var _grid_width := 12
var _grid_height := 12
var _move_history: Array[Dictionary] = []
var _initial_state: Dictionary
var _is_animating := false
var _anim_count := 0
var _level_active := false


func set_grid_origin(origin: Vector2) -> void:
	_grid_origin = origin


func set_grid_size(width: int, height: int) -> void:
	_grid_width = width
	_grid_height = height


func begin_level() -> void:
	_seeds.clear()
	_bases.clear()
	_walls.clear()
	_move_history.clear()
	_is_animating = false
	_anim_count = 0
	_level_active = false
	_player_node = null


func register_entity(entity_type: String, grid_pos: Vector2i, node: Node2D) -> void:
	match entity_type:
		"player":
			_player_pos = grid_pos
			_player_node = node
		"spirit_seed":
			_seeds.append({"pos": grid_pos, "node": node})
		"star_base":
			_bases.append({"pos": grid_pos, "node": node})
		"wall":
			_walls.append(grid_pos)


func finalize_level() -> void:
	_initial_state = _snapshot()
	_level_active = true
	move_count_changed.emit(0)
	level_ready.emit()


func request_move(direction: Vector2i) -> bool:
	if _is_animating or not _level_active:
		return false

	var target_pos := _player_pos + direction

	if not _is_in_bounds(target_pos):
		return false

	var entity := _get_entity_at(target_pos)

	if entity.is_empty():
		_save_state()
		_player_pos = target_pos
		_animate_node(_player_node, target_pos)
		_post_move_check()
		return true

	if entity.type == "wall":
		return false

	if entity.type == "spirit_seed" or entity.type == "star_base":
		var push_target := target_pos + direction
		if not _is_in_bounds(push_target):
			return false
		if not _get_entity_at(push_target).is_empty():
			return false

		_save_state()
		_update_pushable_position(entity, push_target)
		_player_pos = target_pos
		_animate_node(entity.node, push_target)
		_animate_node(_player_node, target_pos)
		_post_move_check()
		return true

	return false


func undo() -> void:
	if _move_history.is_empty() or _is_animating or not _level_active:
		return

	var state := _move_history.pop_back() as Dictionary
	_restore_state(state)
	move_count_changed.emit(_move_history.size())


func reset_level() -> void:
	if _is_animating or not _level_active:
		return

	_move_history.clear()
	_restore_state(_initial_state.duplicate(true))
	move_count_changed.emit(0)


func get_move_count() -> int:
	return _move_history.size()


func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return _grid_origin + Vector2(grid_pos.x * CELL_SIZE, grid_pos.y * CELL_SIZE)


func world_to_grid(world_pos: Vector2) -> Vector2i:
	var local := world_pos - _grid_origin
	return Vector2i(roundi(local.x / CELL_SIZE), roundi(local.y / CELL_SIZE))


func _is_in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < _grid_width and pos.y >= 0 and pos.y < _grid_height


func _get_entity_at(pos: Vector2i) -> Dictionary:
	if pos in _walls:
		return {"type": "wall"}

	if _player_pos == pos:
		return {"type": "player"}

	for seed_data in _seeds:
		if seed_data.pos == pos:
			return {"type": "spirit_seed", "node": seed_data.node, "ref": seed_data}

	for base_data in _bases:
		if base_data.pos == pos:
			return {"type": "star_base", "node": base_data.node, "ref": base_data}

	return {}


func _update_pushable_position(entity: Dictionary, new_pos: Vector2i) -> void:
	entity.ref.pos = new_pos


func _post_move_check() -> void:
	_update_seed_visuals()
	move_count_changed.emit(_move_history.size())
	if _check_win():
		_level_active = false
		level_completed.emit()


func _check_win() -> bool:
	for seed_data in _seeds:
		var on_base := false
		for base_data in _bases:
			if seed_data.pos == base_data.pos:
				on_base = true
				break
		if not on_base:
			return false
	return true


func _update_seed_visuals() -> void:
	for base_data in _bases:
		base_data.node.set_occupied(false)
	for seed_data in _seeds:
		var matched := false
		for base_data in _bases:
			if seed_data.pos == base_data.pos:
				matched = true
				base_data.node.set_occupied(true)
				break
		seed_data.node.set_matched(matched)


func _snapshot() -> Dictionary:
	var seed_positions: Array[Vector2i] = []
	for s in _seeds:
		seed_positions.append(s.pos)
	var base_positions: Array[Vector2i] = []
	for b in _bases:
		base_positions.append(b.pos)
	return {
		"player_pos": _player_pos,
		"seed_positions": seed_positions,
		"base_positions": base_positions,
	}


func _save_state() -> void:
	_move_history.append(_snapshot())


func _restore_state(state: Dictionary) -> void:
	_player_pos = state.player_pos
	_animate_node(_player_node, _player_pos)

	var seed_positions: Array = state.seed_positions
	for i in seed_positions.size():
		_seeds[i].pos = seed_positions[i]
		_animate_node(_seeds[i].node, seed_positions[i])

	var base_positions: Array = state.base_positions
	for i in base_positions.size():
		_bases[i].pos = base_positions[i]
		_animate_node(_bases[i].node, base_positions[i])

	_update_seed_visuals()


func _animate_node(node: Node2D, target_grid: Vector2i) -> void:
	var target_world := grid_to_world(target_grid)
	_is_animating = true
	_anim_count += 1
	var tween := create_tween()
	tween.tween_property(node, "position", target_world, MOVE_DURATION)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	var count_snapshot := _anim_count
	tween.finished.connect(func(): _on_anim_finished(count_snapshot), CONNECT_ONE_SHOT)


func _on_anim_finished(expected_count: int) -> void:
	if expected_count == _anim_count:
		_is_animating = false
		_anim_count = 0
