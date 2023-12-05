extends Node
class_name InputSynchronizer

@export var direction: Vector2 = Vector2.ZERO


func _ready():
	NetworkTime.before_tick_loop.connect(_gather)


func _gather():
	if !is_multiplayer_authority():
		return
	
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
