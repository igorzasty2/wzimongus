class_name Vent
extends Node2D

@export var allow_crewmate_vent: bool = false
@export var vent_target_list : Array[Vent] = []
@onready var sprite_2d = $Sprite2D

var vent_direction_button = preload("res://scenes/sabotages/vent/vent_direction_button/vent_direction_button.tscn")
var vent_direction_button_list = []

const DIRECTION_BUTTON_DISTANCE_MULTIPLIER = 60

var is_player_in_vent = false

var player_body

var in_range_color = [180, 0, 0, 255]
var out_of_range_color = [0, 0, 0, 0]

func _ready():
	set_process_input(false)
	
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

# Obsługuje input wejścia do venta
func _input(event):
	if event.is_action_pressed("use_vent"):
		use_vent()
		print(GameManager._current_player)

# Obsługuje użycie venta
func use_vent():
	if is_player_in_vent:
		exit_vent()
	elif !is_player_in_vent:
		enter_vent()

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
	# Zapobiega przeniesieniu się do innego venta i wyjściu w tym samym momencie
	set_process_input(false)
	
	move_to_vent(id)

# Obsługuje przeniesienie gracza do innego venta
func move_to_vent(id):
	# Obsługuje vent startowy
	change_dir_bttns_visibility(false)
	is_player_in_vent = false

	# Obsługuje vent docelowy
	vent_target_list[id].is_player_in_vent = true
	vent_target_list[id].change_dir_bttns_visibility(true)
	
	move_to_vent_server.rpc(id)

# Obsługuje przeniesienie gracza do innego venta od strony serwera
@rpc("any_peer", "call_local", "reliable")
func move_to_vent_server(id):
	if player_body!=null:
		player_body.teleport_position = vent_target_list[id].position - Vector2(0,50)
	else:
		print("ERROR ",player_body)

# Obsługuje wejście gracza do venta
func enter_vent():
	GameManager.set_input_status(false)
	is_player_in_vent = true
	change_dir_bttns_visibility(true)
	
	enter_vent_server.rpc()

# Obsługuje wejście gracza do venta od strony serwera
@rpc("any_peer", "call_local", "reliable")
func enter_vent_server():
	print("vent entered")
	if player_body!=null:
		# Przesuwa gracza do venta
		player_body.move_toward_position = self.position - Vector2(0,50)
#		player_body.visible = false
		print(player_body.visible)
	else:
		print("ERROR ",player_body)

# Obsługuje wyjście gracza z venta
func exit_vent():
	is_player_in_vent = false
	GameManager.set_input_status(true)
	change_dir_bttns_visibility(false)
	
	exit_vent_server.rpc()

# Obsługuje wyjście gracza z venta od strony serwera
@rpc("any_peer", "call_local", "reliable")
func exit_vent_server():
	if player_body!=null:
		player_body.visible = true
	else:
		print("ERROR ",player_body)

# Zmienia vidoczność przycisków kierunkowych
func change_dir_bttns_visibility(visibility:bool):
	for dir_butt in vent_direction_button_list:
		dir_butt.visible = visibility

# Obsługuje wejście gracza w obszar w którym może ventować
func _on_area_2d_body_entered(body):
	print("body entered: ", body, multiplayer.get_unique_id(), GameManager._current_player, " ", body.player_name) # id, body, current_player.username
	if can_use_vent() || allow_crewmate_vent:
		set_process_input(true)
		
		player_body = body
		
		if body.name.to_int() == multiplayer.get_unique_id():
			toggle_highlight(true)

# Obsługuje wyjście gracza z obszaru w którym może ventować
func _on_area_2d_body_exited(body):
	if can_use_vent() || allow_crewmate_vent:
		set_process_input(false)
		
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
	return GameManager._current_player["impostor"] && !GameManager._current_player["died"]
	
