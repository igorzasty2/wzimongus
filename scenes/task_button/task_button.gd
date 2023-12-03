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

var _in_range_task_color = [0.3, 0.9, 0.5, 1]
var _out_of_range_task_color = [0.5, 0.5, 0.5, 1]
var _disabled_task_color = [0, 0, 0, 0]

var _enabled_line_thickness = 10.0
var _disabled_line_thickness = 0.0

var _is_player_inside : bool = false

@onready var sprite_node = get_node("Sprite2D")

func _ready():
	sprite_node.texture = sprite
	sprite_node.scale = Vector2(scale_factor, scale_factor)
	
	if not disabled:
		# Ustawia domyślny outline dla miejscu taska 
		sprite_node.material.set_shader_parameter('line_color', _out_of_range_task_color)
		sprite_node.material.set_shader_parameter('line_thickness', _enabled_line_thickness)
#	else:
#		body_entered.disconnect(_on_body_entered)
#		body_exited.disconnect(_on_body_exited)


func _on_body_entered(body):
	print("yo")
	if "id" in body and body.id == multiplayer.get_unique_id() and not disabled:
		_is_player_inside = true
		sprite_node.material.set_shader_parameter('line_color', _in_range_task_color)
		TaskManager.current_task_id = task_id


func _on_body_exited(body):
	print(body.get_name())
	
	if "id" in body and body.id == multiplayer.get_unique_id() and not disabled:
		_is_player_inside = false
		sprite_node.material.set_shader_parameter('line_color', _out_of_range_task_color)
		TaskManager.current_task_id = null


func enable_task(server_task_id):
	sprite_node.material.set_shader_parameter('line_color', _out_of_range_task_color)
	sprite_node.material.set_shader_parameter('line_thickness', _enabled_line_thickness)
#	body_entered.connect(_on_body_entered)
#	body_exited.connect(_on_body_exited)
	task_id = server_task_id
	disabled = false
	

func disable_task():
#	body_entered.disconnect(_on_body_entered)
#	body_exited.disconnect(_on_body_exited)
	sprite_node.material.set_shader_parameter('line_color', _out_of_range_task_color)
	sprite_node.material.set_shader_parameter('line_thickness', _disabled_line_thickness)
