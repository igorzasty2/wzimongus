## Główna klasa gracza
class_name Player
extends CharacterBody2D


## Prędkość poruszania się gracza.
@export var walking_speed: float = 600.0
## Prędkość teleportacji gracza do venta.
@export var venting_speed: float = 1500.0

## Ostatni kierunek poziomego ruchu gracza.
var direction_last_x: float = -1

## Czy gracz jest sterowany automatycznie.
var is_walking_to_destination: bool = false
## Pozycja docelowa do której gracz się automatycznie porusza.
var destination_position: Vector2 = Vector2.ZERO

var can_use_vent: bool = false
var is_in_vent: bool = false
var is_moving_through_vent: bool = false

@onready var input: InputSynchronizer = $Input
@onready var rollback_synchronizer: RollbackSynchronizer = $RollbackSynchronizer
@onready var username_label: Label = $UsernameLabel
@onready var animation_tree: AnimationTree = $Skins/AltAnimationTree

@onready var initial_collision_mask: int = collision_mask

func _ready():
	# Gracz jest własnością serwera.
	set_multiplayer_authority(1)

	# Wejście gracza jest własnością gracza.
	input.set_multiplayer_authority(name.to_int())

	# Konfiguruje synchronizację.
	rollback_synchronizer.process_settings()

	# Ustawia etykietę z nazwą gracza.
	username_label.text = GameManager.get_registered_player_key(name.to_int(), "username")

	# Aktywuje drzewo animacji postaci.
	animation_tree.active = true

	# Aktualizuje parametry animacji postaci.
	animation_tree["parameters/idle/blend_position"] = Vector2(direction_last_x, 0)
	animation_tree["parameters/walk/blend_position"] = Vector2(direction_last_x, 0)


func _process(_delta):
	# Aktualizuje parametry animacji postaci.
	var direction = input.direction.normalized()
	_update_animation_parameters(direction)


func _rollback_tick(delta, _tick, _is_fresh):
	# Odpowiada za przesunięcie gracza do venta i za przeniesienie z venta do innego venta
	if is_moving_through_vent && _is_fresh:
		if is_walking_to_destination:
			if global_position.distance_to(destination_position) <= walking_speed / NetworkTime.tickrate:
				global_position = destination_position
				input.direction = Vector2.ZERO

				for i in GameManager.get_registered_players():
					if name.to_int() == i:
						continue
					
					toggle_visible.rpc_id(i, false)

				# do zrobienia: w tym miejscu włączyć animacje wejścia do venta

				if name.to_int() == GameManager.get_current_player_id():
					vent_toggle_dir_bttns(true)

				is_moving_through_vent = false
				is_walking_to_destination = false
		else:
			global_position = global_position.move_toward(destination_position, delta * venting_speed * NetworkTime.physics_factor)

			if global_position == destination_position:
				if name.to_int() == GameManager.get_current_player_id():
					vent_toggle_dir_bttns(true)

				is_moving_through_vent = false
				can_use_vent = true

	# Oblicza kierunek ruchu na podstawie wejścia użytkownika.
	velocity = input.direction.normalized() * walking_speed

	# Porusza postacią i obsługuje kolizje.
	velocity *= NetworkTime.physics_factor
	move_and_slide()
	velocity /= NetworkTime.physics_factor


## Aktualizuje parametry animacji postaci.
func _update_animation_parameters(direction):
	# Ustawia parametry animacji w zależności od stanu ruchu.
	if direction == Vector2.ZERO:
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false
	else:
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/is_moving"] = true
		if direction.x != 0:
			animation_tree["parameters/idle/blend_position"] = direction
			animation_tree["parameters/walk/blend_position"] = direction
			direction_last_x = direction.x
		else:
			animation_tree["parameters/idle/blend_position"] = Vector2(direction_last_x, direction.y)
			animation_tree["parameters/walk/blend_position"] = Vector2(direction_last_x, direction.y)


func _input(event):
	# Obsługuje użycie venta
	if event.is_action_pressed("use_vent") && !GameManager.get_current_game_key("paused") && can_use_vent:
		use_vent()
	if event.is_action_pressed("report"):
		print(name," | position: ",position)


## Sprawdza czy gracz jest impostorem i nie jest martwy lub czy jest włączone ventowanie crewmate
func can_use_vent():
	var vent = get_nearest_vent()
	if vent != null:
		return vent.can_use_vent() || vent.allow_crewmate_vent
	return null


## Obsługuje użycie venta
func use_vent():
	if is_in_vent:
		exit_vent_server.rpc_id(1)
	else:
		enter_vent_server.rpc_id(1)


@rpc("any_peer", "call_local", "reliable")
## Obsługuje wejście do venta
func enter_vent_server():
	if !name.to_int() == multiplayer.get_remote_sender_id():
		return

	var vent = get_nearest_vent()

	if vent != null:
		enter_vent.rpc_id(name.to_int(), vent.global_position)
		enter_vent(vent.global_position)


@rpc("call_local", "reliable")
## Obsługuje wejście do venta na serwerze
func enter_vent(vent_position):
	# Przesuwa gracza do venta
	# do zrobienia: w tym miejscu wyłączyć możliwość zabicia
	# do zrobienia: w tym miejscu wyłączyć możliwość reportowania
	if name.to_int() == GameManager.get_current_player_id():
		GameManager.set_input_status(false)

	is_in_vent = true
	collision_mask = 0
	destination_position = vent_position - Vector2(0, 50)
	is_moving_through_vent = true
	is_walking_to_destination = true


@rpc("any_peer", "call_local", "reliable")
func exit_vent_server():
	if !name.to_int() == multiplayer.get_remote_sender_id():
		return

	var vent = get_nearest_vent()
	if vent!=null:
		#if position == vent.position - Vector2(0,50): # TYMCZASOWO ZAKOMENTOWANE
			# do zrobienia: w tym miejscu włączyć animacje wyjścia z venta
			exit_vent.rpc_id(name.to_int())
			exit_vent()


@rpc("call_local", "reliable")
## Obsługuje wyjście z venta
func exit_vent():
	var vent = get_nearest_vent()
	if vent!=null:
		if name.to_int() == GameManager.get_current_player_id():
			vent.change_dir_bttns_visibility(false)
			GameManager.set_input_status(true)

		is_in_vent = false
		collision_mask = initial_collision_mask

		toggle_visible.rpc(true)
				
		# do zrobienia: w tym miejscu włączyć możliwość zabicia
		# do zrobienia: w tym miejscu włączyć możliwość reportowania


## Zwraca vent najbliżej gracza w odległości mniejszej niz 300
func get_nearest_vent():
	var vent_system_amount = get_parent().get_parent().get_node("Vents").get_child_count()
	
	for i in range(0,vent_system_amount):
		var vent_list = get_parent().get_parent().get_node("Vents").get_child(i).get_children()
		for vent in vent_list:
			# Sprawdza czy odległość mniejsza niż 300
			if position.distance_to(vent.position- Vector2(0,50)) < 300:
				return vent
	return null


## Przełącza widoczność przycisków kierunkowych venta - wywoływane lokalnie w _rollback_tick
func vent_toggle_dir_bttns(is_on:bool):
	var vent = get_nearest_vent()
	if vent != null:
		vent.change_dir_bttns_visibility(is_on)


@rpc("any_peer", "call_local", "reliable")
## Zmienia widoczność gracza na serwerze
func toggle_visible(is_visible: bool):
	visible = is_visible

	
@rpc("any_peer", "call_local", "reliable")
## Zmienia wartość maski kolizji
func change_collision_mask(value):
	collision_mask = value
