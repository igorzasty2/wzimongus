extends Area2D

@export var sprite : Texture2D
@export var scale_factor : float = 1

var _in_range_color = [0.3, 0.9, 0.5, 1]
var _out_of_range_color = [0.5, 0.5, 0.5, 1]

var _line_thickness = 10.0

var _is_player_inside: bool = false

@onready var sprite_node = $Sprite2D


func _ready():
	sprite_node.texture = sprite
	sprite_node.scale = Vector2(scale_factor, scale_factor)
	sprite_node.material = sprite_node.material.duplicate()
	sprite_node.material.set_shader_parameter('line_color', _out_of_range_color)
	sprite_node.material.set_shader_parameter('line_thickness', _line_thickness)


func _input(event):
	if event.is_action_pressed("interact") and _is_player_inside:
		get_parent().get_node("SkinSelector").show()


func _on_body_entered(body):
	if body.name.to_int() == GameManager.get_current_player_id():
		_is_player_inside = true
		sprite_node.material.set_shader_parameter('line_color', _in_range_color)


func _on_body_exited(body):
	if body.name.to_int() == GameManager.get_current_player_id():
		_is_player_inside = false
		sprite_node.material.set_shader_parameter('line_color', _out_of_range_color)
