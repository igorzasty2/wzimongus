extends Node
class_name InputSynchronizer

@export var direction: Vector2 = Vector2.ZERO
var is_disabled: bool = false


func _ready():
	NetworkTime.before_tick_loop.connect(_gather)

	await get_tree().process_frame

	if is_multiplayer_authority():
		GameManager.input_status_changed.connect(_on_input_status_changed)


func _gather():
	if !is_multiplayer_authority():
		return

	if is_disabled:
		direction = Vector2.ZERO
		return

	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")


func _on_input_status_changed(state: bool):
	is_disabled = !state
