extends CanvasLayer

@onready var move_label: Label = $TopBar/MoveCount
@onready var win_panel: Panel = $WinPanel
@onready var undo_button: Button = $TopBar/UndoButton
@onready var reset_button: Button = $TopBar/ResetButton


func _ready() -> void:
	LevelManager.move_count_changed.connect(_on_move_count_changed)
	LevelManager.level_completed.connect(_on_level_completed)
	if win_panel:
		win_panel.visible = false
	if undo_button:
		undo_button.pressed.connect(LevelManager.undo)
	if reset_button:
		reset_button.pressed.connect(LevelManager.reset_level)


func _on_move_count_changed(count: int) -> void:
	if move_label:
		move_label.text = "步数: %d" % count


func _on_level_completed() -> void:
	if win_panel:
		win_panel.visible = true
