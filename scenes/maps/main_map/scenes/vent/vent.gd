class_name Vent
extends Node2D

@export var allow_crewmate_vent: bool = false
@export var vent_target_list : Array[Vent] = []
@onready var sprite_2d = $Sprite2D

var vent_direction_button = preload("res://scenes/maps/main_map/scenes/vent/vent_direction_button/vent_direction_button.tscn")
var vent_direction_button_list = []

const DIRECTION_BUTTON_DISTANCE_MULTIPLIER = 60

var in_range_color = [180, 0, 0, 255]
var out_of_range_color = [0, 0, 0, 0]


func _ready():
	# Ukrywa podświetlenie venta
	toggle_highlight(false)
	
	var dir_id = 0
	# Instancjonuje przycisk dla każdego docelowego venta
	for target_vent in vent_target_list:
		# Oblicza kierunek przycisku
		var direction_button_pos : Vector2 = (target_vent.position - position).normalized()
		instantiante_direction_button(direction_button_pos * DIRECTION_BUTTON_DISTANCE_MULTIPLIER)
		vent_direction_button_list[-1].id = dir_id
		dir_id += 1


# Instancjonuje przycisk kierunkowy w danym miejscu
func instantiante_direction_button(pos : Vector2):
	var vent_dir_bttn_instance = vent_direction_button.instantiate()
	# Łączy instancje przycisku
	vent_dir_bttn_instance.direction_button_pressed.connect(_on_direction_button_pressed)
	
	# Ustawia pozycję przycisku
	vent_dir_bttn_instance.position = pos
	# Ustawia rotację przycisku w kierunku docelowego venta
	vent_dir_bttn_instance.rotation = pos.angle()
	
	add_child(vent_dir_bttn_instance)
	vent_direction_button_list.append(vent_dir_bttn_instance)


# Obsługuje naciśnięcie przyciku kierunkowego
func _on_direction_button_pressed(id):
	move_to_vent(id)


# Obsługuje przeniesienie gracza do innego venta
func move_to_vent(id):
	# Zmienia widoczność przycisków ventu startowego
	change_dir_bttns_visibility(false)
	
	move_to_vent_server.rpc_id(1, id)

	var player = get_tree().root.get_node("Game/Maps/MainMap/Players/" + str(GameManager.get_current_player_id()))
	player.can_player_use_vent = false
	player.is_vent_moving = true
	player.vent_final_position = vent_target_list[id].position - Vector2(0, 50)
	
	# Zmienia widoczność przycisków ventu docelowego
	vent_target_list[id].change_dir_bttns_visibility(true)


# Obsługuje przeniesienie gracza do innego venta od strony serwera
@rpc("any_peer", "call_local", "reliable")
func move_to_vent_server(id):
	var player = get_tree().root.get_node("Game/Maps/MainMap/Players/" + str(multiplayer.get_remote_sender_id()))
	player.can_player_use_vent = false
	player.is_vent_moving = true
	player.vent_final_position = vent_target_list[id].position - Vector2(0, 50)


# Zmienia vidoczność przycisków kierunkowych
func change_dir_bttns_visibility(visibility:bool):
	for dir_butt in vent_direction_button_list:
		dir_butt.visible = visibility


# Obsługuje wejście gracza w obszar w którym może ventować
func _on_area_2d_body_entered(body):
	if can_use_vent() || allow_crewmate_vent:
		
		if body.is_in_vent != true:
			body.can_player_use_vent = true
		
		if body.name.to_int() == multiplayer.get_unique_id():
			toggle_highlight(true)


# Obsługuje wyjście gracza z obszaru w którym może ventować
func _on_area_2d_body_exited(body):
	if can_use_vent() || allow_crewmate_vent:
		
		if body.is_in_vent != true:
			body.can_player_use_vent = false
		
		if body.name.to_int() == multiplayer.get_unique_id():
			toggle_highlight(false)


# Włącza i wyłącza podświetlenie venta
func toggle_highlight(is_on: bool):
	if is_on:
		sprite_2d.material.set_shader_parameter('line_color', in_range_color)
	else:
		sprite_2d.material.set_shader_parameter('line_color', out_of_range_color)


# Sprawdza czy gracz jest impostorem i nie jest martwy
func can_use_vent():
	return GameManager.get_current_player_key("impostor") && !GameManager.get_current_player_key("died")
