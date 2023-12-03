extends Area2D

# parametry dla Sprite2D
@export var sprite : Texture2D
@export var scale_factor : float = 1

# Task ID przekazany przez serwer 
@export var task_id : int

# czy gracz wylosował tego taska
@export var disabled = true

# minigra która będzie włączona przez ten przecisk
@export var minigame_scene : PackedScene

var _is_player_inside : bool = false

func _ready():
	$Sprite2D.texture = sprite
	$Sprite2D.scale = Vector2(scale_factor, scale_factor)
	
	if not disabled:
		# Ustawia domyślny outline dla miejscu taska 
		$Sprite2D.material.set_shader_parameter('line_color', [0.5, 0.5, 0,5, 1])
		$Sprite2D.material.set_shader_parameter('line_thickness', 10.0)
	else:
		body_entered.disconnect(_on_body_entered)
		body_exited.disconnect(_on_body_exited)


func _on_body_entered(body):
	if "id" in body and body.id == multiplayer.get_unique_id():
		_is_player_inside = true
		$Sprite2D.material.set_shader_parameter('line_color', [0.3, 0.9, 0,5, 1])
		TaskManager.current_task_id = task_id


func _on_body_exited(body):
	print(body.get_name())
	
	if "id" in body and body.id == multiplayer.get_unique_id():
		_is_player_inside = false
		$Sprite2D.material.set_shader_parameter('line_color', [0.5, 0.5, 0,5, 1])
		TaskManager.current_task_id = null


func enable_task(task_id):
	$Sprite2D.material.set_shader_parameter('line_color', [0.5, 0.5, 0,5, 1])
	$Sprite2D.material.set_shader_parameter('line_thickness', 10.0)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	disabled = false
