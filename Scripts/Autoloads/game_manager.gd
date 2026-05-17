extends Node

var current_chapter := 1
var current_level := 1


func _ready() -> void:
	_load_current_level()


func _load_current_level() -> void:
	var level_path := "res://Scenes/Levels/test_level.tscn"
	var level_scene := load(level_path) as PackedScene
	if level_scene:
		var level := level_scene.instantiate()
		get_tree().current_scene.add_child(level)
