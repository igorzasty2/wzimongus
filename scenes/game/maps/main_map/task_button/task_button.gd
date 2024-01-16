## Klasa punktu interakcji z zadaniem.
class_name TaskButton
extends Area2D

## Sprite wykorzystany jako przycisk zadania.
@export var sprite: Texture2D
## Współczynnik skalowania sprite'a zadania.
@export var scale_factor: float = 1
## Task ID przekazany przez serwer
@export var task_id: int
## Określa dostępność taska graczowi.
@export var disabled = true
## Określa, czy punkt interakcji zawiera w sobie minigrę.
@export var is_minigame = true
## Scena minigry która będzie włączona przez ten przycisk.
@export var minigame_scene: PackedScene

## Kolor zarysu, gdy gracz znajduje się w zasięgu punktu interakcji..
var _in_range_task_color = [0.3, 0.9, 0.5, 1]
## Kolor zarysu dostępengo punktu interakcji kiedy znajdzie się on poza zasięgiem gracza.
var _out_of_range_task_color = [0.5, 0.5, 0.5, 1]
## Szerokość zarysu punktu interakcji.
var _enabled_line_thickness = 10.0
## Szerokość zarysu punktu interakcji który nie jest dostępny.
var _disabled_line_thickness = 0.0
## Określa czy gracz znajduje się wewnątrz punktu interakcji.
var _is_player_inside: bool = false

## Referecja do node'a sprite'a.
@onready var _sprite_node = get_node("Sprite2D")
## Referencja do node'a okna minigry.
@onready var _minigame_window = get_tree().root.get_node("Game/Maps/MainMap/MinigameWindow")


func _ready():
	_sprite_node.texture = sprite
	_sprite_node.scale = Vector2(scale_factor, scale_factor)

	if not disabled:
		_sprite_node.material.set_shader_parameter("line_color", _out_of_range_task_color)
		_sprite_node.material.set_shader_parameter("line_thickness", _enabled_line_thickness)

	if !is_minigame:
		_sprite_node.material.set_shader_parameter("line_color", _out_of_range_task_color)
		_sprite_node.material.set_shader_parameter("line_thickness", _enabled_line_thickness)
		disabled = false


## Zapisuje ID punktu interakcji w zasięgu którego znajduje się gracz i włącza odpowiedni zarys.
func _on_body_entered(body):
	if body.name.to_int() == GameManagerSingleton.get_current_player_id() && !disabled && !body.is_in_vent:
		_is_player_inside = true
		_sprite_node.material.set_shader_parameter("line_color", _in_range_task_color)
		_minigame_window.show_use_button(minigame_scene)
		TaskManagerSingleton.current_task_id = task_id


## Usuwa ID punktu interakcji i włącza odpowiedni zarys.
func _on_body_exited(body):
	if body.name.to_int() == GameManagerSingleton.get_current_player_id() && !disabled:
		_is_player_inside = false
		_sprite_node.material.set_shader_parameter("line_color", _out_of_range_task_color)
		_minigame_window.hide_use_button()
		TaskManagerSingleton.current_task_id = null


## Udostępnia punkt interakcji graczowi.
func enable_task(server_task_id):
	_sprite_node.material.set_shader_parameter("line_color", _out_of_range_task_color)
	_sprite_node.material.set_shader_parameter("line_thickness", _enabled_line_thickness)
	task_id = server_task_id
	disabled = false


## Zamyka dostęp do punktu interakcji.
func disable_task():
	_sprite_node.material.set_shader_parameter("line_color", _out_of_range_task_color)
	_sprite_node.material.set_shader_parameter("line_thickness", _disabled_line_thickness)
	disabled = true
