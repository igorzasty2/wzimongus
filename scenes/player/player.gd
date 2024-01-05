extends CharacterBody2D

@export var speed = 600.0

var last_direction_x: float = -1

@onready var input = $Input
@onready var rollback_synchronizer = $RollbackSynchronizer
@onready var username_label = $UsernameLabel
@onready var animation_tree = $Skins/AltAnimationTree

# Zmienne do obsługi ventów
var is_vent_moving = false
var is_vent_moving_to_vent = false
var vent_final_position = Vector2.ZERO


var can_player_use_vent = false
var is_in_vent = false
var venting_speed = 3
var initial_collision_mask
var is_moving_toward_position = false


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
	animation_tree["parameters/idle/blend_position"] = Vector2(last_direction_x, 0)
	animation_tree["parameters/walk/blend_position"] = Vector2(last_direction_x, 0)
	
	initial_collision_mask = collision_mask


func _process(_delta):
	# Aktualizuje parametry animacji postaci podczas ruchu do venta
	if is_moving_toward_position==true && vent_final_position!=null:
		_update_animation_parameters((vent_final_position-position).normalized())
		return

	# Aktualizuje parametry animacji postaci.
	var direction = input.direction.normalized()
	_update_animation_parameters(direction)


func _rollback_tick(delta, _tick, _is_fresh):
	# Odpowiada za przesunięcie gracza do venta i za przeniesienie z venta do innego venta
	if is_vent_moving && _is_fresh:
		if is_vent_moving_to_vent:
			global_position = global_position.move_toward(vent_final_position, delta * speed * NetworkTime.physics_factor)

			if global_position == vent_final_position:
				for i in GameManager.get_registered_players():
					if name.to_int() == i:
						continue
					
					toggle_visible.rpc_id(i, false)

				# do zrobienia: w tym miejscu włączyć animacje wejścia do venta

				if name.to_int() == GameManager.get_current_player_id():
					vent_toggle_dir_bttns(true)

				is_vent_moving = false
				is_vent_moving_to_vent = false
		else:
			global_position = global_position.move_toward(vent_final_position, delta * speed * venting_speed * NetworkTime.physics_factor)

			if global_position == vent_final_position:
				if name.to_int() == GameManager.get_current_player_id():
					vent_toggle_dir_bttns(true)

				is_vent_moving = false
				can_player_use_vent = true

	# Oblicza kierunek ruchu na podstawie wejścia użytkownika.
	velocity = input.direction.normalized() * speed

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
			last_direction_x = direction.x
		else:
			animation_tree["parameters/idle/blend_position"] = Vector2(last_direction_x, direction.y)
			animation_tree["parameters/walk/blend_position"] = Vector2(last_direction_x, direction.y)


func _input(event):
	# Obsługuje użycie venta
	if event.is_action_pressed("use_vent") && !GameManager.get_current_game_key("paused") && can_player_use_vent:
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
	vent_final_position = vent_position - Vector2(0, 50)
	is_vent_moving = true
	is_vent_moving_to_vent = true


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
