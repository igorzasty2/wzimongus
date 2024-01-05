## Główna klasa gracza.
class_name Player
extends CharacterBody2D


## Prędkość poruszania się.
@export var walking_speed: float = 600.0
## Prędkość teleportacji do venta.
@export var venting_speed: float = 1500.0

## Ostatni kierunek poziomego ruchu gracza.
var direction_last_x: float = -1

## Czy może używać venta.
var can_use_vent: bool = false
## Czy jest w vencie.
var is_in_vent: bool = false
## Czy jest w trakcie poruszania się przez venta lub do venta.
var is_moving_through_vent: bool = false

## Referencja do wejścia gracza.
@onready var input: InputSynchronizer = $Input
## Referencja do synchronizatora rollbacku.
@onready var rollback_synchronizer: RollbackSynchronizer = $RollbackSynchronizer
## Referencja do etykiety z nazwą gracza.
@onready var username_label: Label = $UsernameLabel
## Referencja do drzewa animacji postaci.
@onready var animation_tree: AnimationTree = $Skins/AltAnimationTree

## Początkowa maska kolizji.
@onready var initial_collision_mask: int = collision_mask


## Zwraca najbliższy vent.
func get_nearest_vent() -> Vent:
	var vent_systems = get_tree().root.get_node("Game/Maps/MainMap/Vents").get_children()

	for i in vent_systems:
		var vents = i.get_children()

		for j in vents:
			if position.distance_to(j.global_position - Vector2(0, 50)) < 300:
				return j

	return null


## Zwraca czy gracz może używać ventów.
func has_vent_permission() -> bool:
	return GameManager.get_registered_player_key(name.to_int(), "is_lecturer") && !GameManager.get_registered_player_key(name.to_int(), "is_dead")


@rpc("call_local", "reliable")
## Zmienia widoczność gracza.
func toggle_visibility(is_enabled: bool):
	visible = is_enabled


func _ready():
	# Gracz jest własnością serwera.
	set_multiplayer_authority(1)

	# Wejście gracza jest własnością gracza.
	input.set_multiplayer_authority(name.to_int())

	# Konfiguruje synchronizator rollbacku.
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


func _rollback_tick(delta, _tick, is_fresh):
	# Odpowiada za poruszanie się przez venta.
	if is_moving_through_vent && is_fresh:
		# Jeśli gracz wchodzi do venta.
		if input.is_walking_to_destination:
			# Jeśli gracz jest w granicy błędu wejścia do venta.
			if global_position.distance_to(input.destination_position) <= walking_speed / NetworkTime.tickrate:
				# Przesuwa gracza do środka venta.
				global_position = input.destination_position
				input.direction = Vector2.ZERO

				# Wyłącza widoczność gracza.
				if multiplayer.is_server():
					for i in GameManager.get_registered_players():
						if name.to_int() == i:
							continue

						toggle_visibility.rpc_id(i, false)

				# Włącza widoczność przycisków kierunkowych venta.
				if name.to_int() == GameManager.get_current_player_id():
					_toggle_vent_buttons(true)

				input.is_walking_to_destination = false
				is_moving_through_vent = false

		# Jeśli gracz przemieszcza się między ventami.
		else:
			# Przesuwa gracza w kierunku docelowego venta.
			global_position = global_position.move_toward(input.destination_position, delta * venting_speed * NetworkTime.physics_factor)

			# Jeśli gracz dotał do docelowego venta.
			if global_position == input.destination_position:
				# Włącza widoczność przycisków kierunkowych venta.
				if name.to_int() == GameManager.get_current_player_id():
					_toggle_vent_buttons(true)

				is_moving_through_vent = false
				can_use_vent = true

	# Oblicza kierunek ruchu na podstawie wejścia użytkownika.
	velocity = input.direction.normalized() * walking_speed

	# Porusza postacią i obsługuje kolizje.
	velocity *= NetworkTime.physics_factor
	move_and_slide()
	velocity /= NetworkTime.physics_factor


## Aktualizuje parametry animacji postaci.
func _update_animation_parameters(direction: Vector2):
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
	# Obsługuje użycie venta.
	if event.is_action_pressed("use_vent") && can_use_vent && !GameManager.get_current_game_key("paused"):
		_use_vent()


## Używa venta.
func _use_vent():
	if !is_in_vent:
		_request_vent_entering.rpc_id(1)
	else:
		_request_vent_exiting.rpc_id(1)


@rpc("any_peer", "call_local", "reliable")
## Obsługuje żądanie wejścia do venta.
func _request_vent_entering():
	var id = multiplayer.get_remote_sender_id()

	if !name.to_int() == id:
		return

	var vent = get_nearest_vent()

	if vent == null:
		return

	if !has_vent_permission() && !vent.allow_student_venting:
		return

	if name.to_int() != 1:
		_enter_vent(vent.global_position)

	_enter_vent.rpc_id(name.to_int(), vent.global_position)


@rpc("call_local", "reliable")
## Wchodzi do venta.
func _enter_vent(vent_position: Vector2):
	if name.to_int() == GameManager.get_current_player_id():
		GameManager.set_input_status(false)

	is_in_vent = true
	collision_mask = 0
	is_moving_through_vent = true
	input.destination_position = vent_position - Vector2(0, 50)
	input.is_walking_to_destination = true


@rpc("any_peer", "call_local", "reliable")
## Obsługuje żądanie wyjścia z venta.
func _request_vent_exiting():
	var id = multiplayer.get_remote_sender_id()

	if !name.to_int() == id:
		return

	var vent = get_nearest_vent()

	if vent == null:
		return

	if !has_vent_permission() && !vent.allow_student_venting:
		return

	if position != vent.global_position - Vector2(0, 50):
		return

	if name.to_int() != 1:
		_exit_vent()

	_exit_vent.rpc_id(name.to_int())


@rpc("call_local", "reliable")
## Obsługuje wyjście z venta.
func _exit_vent():
	var vent = get_nearest_vent()

	if vent == null:
		return

	if name.to_int() == GameManager.get_current_player_id():
		vent.set_direction_buttons_visibility(false)
		GameManager.set_input_status(true)

	is_in_vent = false
	collision_mask = initial_collision_mask

	if multiplayer.is_server():
		for i in GameManager.get_registered_players():
			if name.to_int() == i:
				continue

			toggle_visibility.rpc_id(i, true)


## Zmienia widoczność przycisków kierunkowych venta.
func _toggle_vent_buttons(is_enabled: bool):
	var vent = get_nearest_vent()

	if vent == null:
		return

	vent.set_direction_buttons_visibility(is_enabled)
