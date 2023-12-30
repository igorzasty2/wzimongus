extends CharacterBody2D

@export var speed = 600.0

var last_direction_x: float = -1

@onready var input = $Input
@onready var rollback_synchronizer = $RollbackSynchronizer
@onready var username_label = $UsernameLabel
@onready var animation_tree = $Skins/AltAnimationTree

# Zmienne do obsługi ventów
var teleport_position = null
var move_toward_position = null
var can_player_use_vent = false
var is_in_vent = false

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


func _process(_delta):
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
	
	# Odpowiada za przesunięcie gracza do venta
	if move_toward_position != null:
		input.direction = move_toward_position - position
		position = position.move_toward(move_toward_position, _delta*speed)
		if position == move_toward_position:
			# do zrobienia: włączyć animacje wejścia do venta
			
			vent_toggle_dir_bttns.rpc_id(name.to_int(),true)
			toggle_visible.rpc(false)
			move_toward_position = null
	
	# Odpowiada za przeniesienie gracza z venta do innego venta
	if teleport_position != null:
		position = teleport_position
		teleport_position = null
		
	# Obsługuje sytuację w której gracz wyjdzie z venta i ventuje w tym samym momencie
	if visible == true && is_in_vent == false && can_player_use_vent == true:
		vent_toggle_dir_bttns.rpc_id(name.to_int(), false)


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


# =========================================================================
# -----------------=============SEKCJA VENTA==============-----------------
# =========================================================================

#
# VENT - TO DO:
# - naprawić ruch gracza w kierunku venta - nie widać animacji na serwerze (przesunięcie gracza do venta już działa) 
# - poprawić błędy związane z area antered/exited
#

func _input(event):
	# Poprawia błędne dane (vent.gd - _on_area_2d_body_entered, _on_area_2d_body_exited czasem działają w złej kolejności przy przenoszeniu się z venta do venta)
	if get_parent().get_parent().name=="MainMap":
		if get_closest_vent()!=null && can_use_vent():
			can_player_use_vent = true

	# Obsługuje użycie venta
	if can_player_use_vent && event.is_action_pressed("use_vent") && !GameManager.get_current_game_key("paused"):
		use_vent()


## Zmienia widoczność gracza na serwerze
@rpc("any_peer", "call_local", "reliable")
func toggle_visible(is_visible:bool):
	visible = is_visible


## Sprawdza czy gracz jest impostorem i nie jest martwy lub czy jest włączone ventowanie crewmate
func can_use_vent():
	var vent = get_closest_vent()
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
		var vent = get_closest_vent()
		
		if vent != null:

			GameManager.set_input_status(false)
			is_in_vent = true
			
			enter_vent_server.rpc(vent.position)
			
			# do zrobienia: w tym miejscu wyłączyć możliwość zabicia


## Obsługuje wejście do venta na serwerze
@rpc("any_peer", "call_local", "reliable")
func enter_vent_server(vent_position):
	# Przesuwa gracza do venta
	move_toward_position = vent_position - Vector2(0,50)


## Obsługuje wyjście z venta
func exit_vent():
	var vent = get_closest_vent()
	if vent!=null:
		if position == vent.position - Vector2(0,50):
			# do zrobienia: włączyć animacje wyjścia z venta
			
			vent.change_dir_bttns_visibility(false)
			
			GameManager.set_input_status(true)
			is_in_vent = false
			
			toggle_visible.rpc(true)
			
			# do zrobienia: w tym miejscu włączyć możliwość zabicia


## Zwraca vent najbliżej gracza w odległości mniejszej niz 300
func get_closest_vent():
	var vent_system_amount = get_parent().get_parent().get_node("Vents").get_child_count()
	
	for i in range(0,vent_system_amount):
		var vent_list = get_parent().get_parent().get_node("Vents").get_child(i).get_children()
		for vent in vent_list:
			# Sprawdza czy odległość mniejsza niż 300
			if position.distance_to(vent.position- Vector2(0,50)) < 300:
				return vent
	return null


## Przełącza widoczność przycisków kierunkowych venta - wywoływane lokalnie w _rollback_tick
@rpc("any_peer", "call_local", "reliable")
func vent_toggle_dir_bttns(is_on:bool):
	var vent = get_closest_vent()
	if vent != null:
		vent.change_dir_bttns_visibility(is_on)
	
