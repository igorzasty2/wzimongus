extends CharacterBody2D

@export var speed = 600.0

var last_direction_x: float = -1

@onready var input = $Input
@onready var rollback_synchronizer = $RollbackSynchronizer
@onready var username_label = $UsernameLabel
@onready var animation_tree = $Skins/AltAnimationTree

# Zmienne do obsługi ventów
var move_toward_position = null
var is_teleport = false
var can_player_use_vent = false
var is_in_vent = false
var venting_speed = 10
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
	if is_moving_toward_position==true && move_toward_position!=null:
		_update_animation_parameters((move_toward_position-position).normalized())
		if position==move_toward_position:
			is_moving_toward_position = false
		return

	# Aktualizuje parametry animacji postaci.
	var direction = input.direction.normalized()
	_update_animation_parameters(direction)


func _rollback_tick(_delta, _tick, _is_fresh):
	# Oblicza kierunek ruchu na podstawie wejścia użytkownika.
	velocity = input.direction.normalized() * speed

	# Porusza postacią i obsługuje kolizje.
	velocity *= NetworkTime.physics_factor
	move_and_slide()
	velocity /= NetworkTime.physics_factor
	
	# Odpowiada za przesunięcie gracza do venta i za przeniesienie z venta do innego venta
	if move_toward_position != null:
		# Przenosi gracza z venta do innego venta
		if is_teleport==true:
			position = position.move_toward(move_toward_position, _delta*speed*venting_speed)
			can_player_use_vent = false
			if position == move_toward_position:
				await get_tree().create_timer(0.1).timeout
				nullify_move_toward_position.rpc()

				vent_toggle_dir_bttns.rpc_id(name.to_int(),true)
				toggle_is_teleport.rpc(false)

				await get_tree().create_timer(0.1).timeout
				can_player_use_vent = true

		# Przesuwa gracza do venta
		else:
			position = position.move_toward(move_toward_position, _delta*speed)
			if position == move_toward_position:
				# do zrobienia: w tym miejscu włączyć animacje wejścia do venta
				
				toggle_visible.rpc(false)
				vent_toggle_dir_bttns.rpc_id(name.to_int(),true)
				
				await get_tree().create_timer(0.1).timeout
				nullify_move_toward_position.rpc()


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
	if can_player_use_vent && event.is_action_pressed("use_vent") && !GameManager.get_current_game_key("paused"):
		use_vent()


@rpc("any_peer", "call_local", "reliable")
## Zmienia widoczność gracza na serwerze
func toggle_visible(is_visible:bool):
	visible = is_visible


@rpc("any_peer", "call_local", "reliable")
## Zmienia move_toward_position na null
func nullify_move_toward_position():
	move_toward_position = null


@rpc("any_peer", "call_local", "reliable")
## Zmienia is_teleport na true/false
func toggle_is_teleport(is_true:bool):
	is_teleport = is_true


## Sprawdza czy gracz jest impostorem i nie jest martwy lub czy jest włączone ventowanie crewmate
func can_use_vent():
	var vent = get_nearest_vent()
	if vent!=null:
		return vent.can_use_vent() || vent.allow_crewmate_vent
	return null


## Obsługuje użycie venta
func use_vent():
	if is_in_vent:
		exit_vent()
	else:
		enter_vent()


## Obsługuje wejście do venta lokalnie
func enter_vent():
	if name.to_int()==GameManager.get_current_player_id():
		var vent = get_nearest_vent()
		
		if vent != null:
			GameManager.set_input_status(false)
			is_in_vent = true
			
			collision_mask = 0
			
			enter_vent_server.rpc(vent.position)
			
			# do zrobienia: w tym miejscu wyłączyć możliwość zabicia
			# do zrobienia: w tym miejscu wyłączyć możliwość reportowania


@rpc("any_peer", "call_local", "reliable")
## Obsługuje wejście do venta na serwerze
func enter_vent_server(vent_position):
	# Przesuwa gracza do venta
	move_toward_position = vent_position - Vector2(0,50)
	is_moving_toward_position = true


## Obsługuje wyjście z venta
func exit_vent():
	var vent = get_nearest_vent()
	if vent!=null:
		if position == vent.position - Vector2(0,50):
			# do zrobienia: w tym miejscu włączyć animacje wyjścia z venta
			
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


@rpc("any_peer", "call_local", "reliable")
## Przełącza widoczność przycisków kierunkowych venta - wywoływane lokalnie w _rollback_tick
func vent_toggle_dir_bttns(is_on:bool):
	var vent = get_nearest_vent()
	if vent != null:
		vent.change_dir_bttns_visibility(is_on)
