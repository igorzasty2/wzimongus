## Klasa obsługująca punkt wyboru skina gracza.
class_name SkinSelectorPoint
extends Area2D

@export var _sprite: Texture2D
@export var _scale_factor: float = 1

var _in_range_color = [0.3, 0.9, 0.5, 1]
var _out_of_range_color = [0.5, 0.5, 0.5, 1]

var _line_thickness = 10.0

var _is_player_inside: bool = false

@onready var _sprite_node = $Sprite2D

# Zmienne do obsługi interface gracza
@onready var _user_interface = get_parent().get_node("LobbyUI")

## Emitowany, gdy zmieni się stan przycisku interakcji.
signal use_button_active(is_active: bool)


func _ready():
	_sprite_node.texture = _sprite
	_sprite_node.scale = Vector2(_scale_factor, _scale_factor)
	_sprite_node.material = _sprite_node.material.duplicate()
	_sprite_node.material.set_shader_parameter("line_color", _out_of_range_color)
	_sprite_node.material.set_shader_parameter("line_thickness", _line_thickness)

	use_button_active.connect(_user_interface.toggle_interact_button_active)


func _input(event):
	if event.is_action_pressed("interact"):
		if GameManagerSingleton.get_current_game_value("is_paused"):
			return

		if GameManagerSingleton.get_current_game_value("is_input_disabled"):
			return

		if !_is_player_inside:
			return

		get_parent().get_node("SkinSelector").show()


func _on_body_entered(body):
	if body.name.to_int() == GameManagerSingleton.get_current_player_id():
		_is_player_inside = true
		_sprite_node.material.set_shader_parameter("line_color", _in_range_color)

		emit_signal("use_button_active", true)


func _on_body_exited(body):
	if body.name.to_int() == GameManagerSingleton.get_current_player_id():
		_is_player_inside = false
		_sprite_node.material.set_shader_parameter("line_color", _out_of_range_color)

		emit_signal("use_button_active", false)
