## Klasa venta.
class_name Vent
extends Node2D


## Lista docelowych ventów.
@export var vent_target_list : Array[Vent] = []
## Dystans przycisku kierunkowego od venta.
@export var direction_button_distance: int = 60
## Czy student może użyć venta.
@export var allow_student_venting: bool = false

var _vent_direction_button = preload("res://scenes/maps/main_map/scenes/vent/vent_direction_button/vent_direction_button.tscn")
var _vent_direction_button_list = []

var _in_range_color = [180, 0, 0, 255]
var _out_of_range_color = [0, 0, 0, 0]

@onready var _sprite_2d = $Sprite2D

## Referencja do node'a venta.
@onready var _vent_light_container = $LightsContainer
## Referencja do kontenera światła venta.
@onready var _vent_light = $LightsContainer/Light 

## Referencja do node'a venta.
@onready var _vent_node = $"."

@onready var _animation_player = $Sprite2D/AnimationPlayer

## Interfejs
var user_interface
## Emitowany gdy przycisk ventowania powinien być włączony/wyłączony
signal vent_button_active(button_name:String, is_active:bool)

## Ustawia widoczność przycisków kierunkowych.
func set_direction_buttons_visibility(visibility:bool):
	for dir_butt in _vent_direction_button_list:
		dir_butt.visible = visibility


func _ready():
	user_interface = get_tree().root.get_node("Game/Maps/MainMap/UserInterface")
	vent_button_active.connect(user_interface.toggle_button_active)
	
	var idx = 0
	# Instancjonuje przycisk dla każdego docelowego venta.
	for target_vent in vent_target_list:
		# Oblicza kierunek przycisku.
		var direction_button_pos : Vector2 = (target_vent.global_position - position).normalized()
		_instantiante_direction_button(direction_button_pos * direction_button_distance)
		_vent_direction_button_list[-1].id = idx
		idx += 1
	
	_vent_light.texture_scale = GameManager.get_server_settings()["lecturer_light_radius"] / _vent_node.global_scale.x

## Instancjonuje przycisk kierunkowy.
func _instantiante_direction_button(pos : Vector2):
	var vent_dir_bttn_instance = _vent_direction_button.instantiate()

	# Łączy instancje przycisku.
	vent_dir_bttn_instance.direction_button_pressed.connect(_on_direction_button_pressed)

	vent_dir_bttn_instance.position = pos
	vent_dir_bttn_instance.rotation = pos.angle()

	add_child(vent_dir_bttn_instance)
	_vent_direction_button_list.append(vent_dir_bttn_instance)


## Obsługuje wciśnięcie przycisku kierunkowego.
func _on_direction_button_pressed(id):
	_request_moving_to_vent.rpc_id(1, id)


@rpc("any_peer", "call_local", "reliable")
## Obsługuje zapytanie o przeniesienie się do innego venta.
func _request_moving_to_vent(vent_id: int):
	var player_id = multiplayer.get_remote_sender_id()
	var player = get_tree().root.get_node("Game/Maps/MainMap/Players/" + str(player_id))

	if !player.has_vent_permission(self):
		return

	if player_id != 1:
		_move_to_vent(player_id, vent_id)

	_move_to_vent.rpc_id(player_id, player_id, vent_id)


@rpc("call_local", "reliable")
## Przenosi gracza do innego venta.
func _move_to_vent(player_id: int, vent_id: int):
	var player = get_tree().root.get_node("Game/Maps/MainMap/Players/" + str(player_id))
	player.can_use_vent = false
	player.is_moving_through_vent = true
	player.input.destination_position = vent_target_list[vent_id].global_position

	# Zmienia widoczność przycisków ventu startowego i docelowego.
	if player_id == GameManager.get_current_player_id():
		set_direction_buttons_visibility(false)
		set_vent_light_visibility_for(player_id, false)
		vent_target_list[vent_id].set_direction_buttons_visibility(true)
		vent_target_list[vent_id].set_vent_light_visibility_for(player_id, true)


## Obsługuje wejście gracza do obszaru w którym może ventować.
func _on_area_2d_body_entered(body):
	if !body.name.to_int() == multiplayer.get_unique_id() && !multiplayer.is_server():
		return

	if !body.has_vent_permission(self):
		return

	if body.is_in_vent != true:
		body.can_use_vent = true

	if body.name.to_int() == multiplayer.get_unique_id():
		_toggle_highlight(true)


## Obsługuje wyjście gracza z obszaru w którym może ventować.
func _on_area_2d_body_exited(body):
	if !body.name.to_int() == multiplayer.get_unique_id() && !multiplayer.is_server():
		return

	if !body.has_vent_permission(self):
		return

	if body.is_in_vent != true:
		body.can_use_vent = false

	if body.name.to_int() == multiplayer.get_unique_id():
		_toggle_highlight(false)


## Zmienia kolor podświetlenia venta.
func _toggle_highlight(is_on: bool):
	_sprite_2d.material.set_shader_parameter('color', _in_range_color if is_on else _out_of_range_color)
	vent_button_active.emit("VentButton", is_on)


## Włącza światło venta kiedy gracz znajduje się wewnątrz.
func set_vent_light_visibility_for(player_id: int, visibility: bool):
	if player_id == GameManager.get_current_player_id():
		_vent_light_container.visible = visibility


@rpc("call_local", "reliable")
## Puszcza animacje ventowania
func play_vent_animation():
	_animation_player.play("vent_animation")
