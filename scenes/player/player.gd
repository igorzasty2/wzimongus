extends CharacterBody2D

# Ostatni kierunek ruchu postaci na osi X.
var last_direction_x: float = 1
# Stała określająca prędkość postaci.
const SPEED = 600.0
var minigame: PackedScene
var minigame_instance:Node2D

# Zmienne do obsługi ventów
var teleport_position = null
var move_toward_position = null
var can_player_use_vent = false
var is_in_vent = false

@export var input: InputSynchronizer

@onready var animation_tree = $Skins/AltAnimationTree
@onready var camera = get_parent().get_parent().get_node("Camera")
@onready var minigame_container = get_parent().get_parent().get_node("Camera").get_node("MinigameContainer")
@onready var use_button:TextureButton = get_parent().get_parent().get_node("Camera").get_node("UseButton")
@onready var close_button:TextureButton = get_parent().get_parent().get_node("Camera").get_node("CloseButton")
@onready var minigame_background:ColorRect = get_parent().get_parent().get_node("Camera").get_node("MinigameBackground")

#
# VENT - TO DO:
# - naprawić ruch gracza w kierunku venta - nie widać animacji na serwerze (przesunięcie gracza do venta już działa)
#

func _ready():
	if input == null:
		input = $Input

	await get_tree().process_frame

	$RollbackSynchronizer.process_settings()

	# Ustawia nazwę użytkownika w etykiecie.
	$UsernameLabel.text = GameManager.get_registered_player_key(name.to_int(), "username")

	# Aktywuje drzewo animacji postaci.
	animation_tree.active = true
	last_direction_x = 1
	use_button.pressed.connect(_on_use_button_pressed)
	close_button.pressed.connect(close_minigame)


func _process(_delta):
	# Aktualizuje parametry animacji.
	var direction = input.direction.normalized()

	_update_animation_parameters(direction)

func _rollback_tick(_delta, _tick, _is_fresh):
	
	# Oblicza kierunek ruchu na podstawie wejścia użytkownika.
	velocity = input.direction.normalized() * SPEED
	
	# Porusza postacią i obsługuje kolizje.
	velocity *= NetworkTime.physics_factor
	move_and_slide()
	velocity /= NetworkTime.physics_factor
	
	# Odpowiada za przesunięcie gracza do venta
	if move_toward_position != null:
		input.direction = move_toward_position - position
		position = position.move_toward(move_toward_position, _delta*SPEED)
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

# Aktualizuje parametry animacji postaci.
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

func show_use_button(id, minigame):
	if id == multiplayer.get_unique_id():
		self.minigame = minigame
		use_button.visible = true
		use_button.disabled = false


func hide_use_button(id):
	if id == multiplayer.get_unique_id():
		minigame = null
		use_button.visible = false
		use_button.disabled = true


func _on_use_button_pressed():
	if minigame != null && minigame_container.get_node("MinigameViewport").get_child_count() == 0:
		summon_window()


func _input(event):
	if (
		event.is_action_pressed("interact") 
		&& minigame != null && !use_button.disabled 
		&& minigame_container.get_node("MinigameViewport").get_child_count() == 0
		&& !GameManager.get_current_game_key("paused")
	):
		summon_window()
	
	# Poprawia błędne dane (vent.gd - _on_area_2d_body_entered, _on_area_2d_body_exited czasem działają w złej kolejności przy przenoszeniu się z venta do venta)
	if get_closest_vent()!=null && can_use_vent():
		can_player_use_vent = true
	
	# Obsługuje użycie venta
	if can_player_use_vent && event.is_action_pressed("use_vent") && !GameManager.get_current_game_key("paused"):
		use_vent()


# Zmienia widoczność gracza na serwerze
@rpc("any_peer", "call_local", "reliable")
func toggle_visible(is_visible:bool):
	visible = is_visible


# Sprawdza czy gracz jest impostorem i nie jest martwy lub czy jest włączone ventowanie crewmate
func can_use_vent():
	var vent = get_closest_vent()
	if vent!=null:
		return vent.can_use_vent() || vent.allow_crewmate_vent
	return null


# Obsługuje użycie venta
func use_vent():
	if is_in_vent:
		exit_vent()
	else:
		enter_vent()


# Obsługuje wejście do venta lokalnie
func enter_vent():
	if name.to_int()==GameManager.get_current_player_id():
		var vent = get_closest_vent()
		
		if vent != null:

			GameManager.set_input_status(false)
			is_in_vent = true
			
			enter_vent_server.rpc(vent.position)
			
			# do zrobienia: w tym miejscu wyłączyć możliwość zabicia


# Obsługuje wejście do venta na serwerze
@rpc("any_peer", "call_local", "reliable")
func enter_vent_server(vent_position):
	# Przesuwa gracza do venta
	move_toward_position = vent_position - Vector2(0,50)


# Obsługuje wyjście z venta
func exit_vent():
	var vent = get_closest_vent()
	if vent!=null:
		# do zrobienia: włączyć animacje wyjścia z venta
		
		vent.change_dir_bttns_visibility(false)
		
		GameManager.set_input_status(true)
		is_in_vent = false
		
		toggle_visible.rpc(true)
		
		# do zrobienia: w tym miejscu włączyć możliwość zabicia


# Zwraca vent najbliżej gracza w odległości mniejszej niz 300
func get_closest_vent():
	var vent_system_amount = get_parent().get_parent().get_node("Vents").get_child_count()
	
	for i in range(0,vent_system_amount):
		var vent_list = get_parent().get_parent().get_node("Vents").get_child(i).get_children()
		for vent in vent_list:
			# Sprawdza czy odległość mniejsza niż 300
			if position.distance_to(vent.position- Vector2(0,50)) < 300:
				return vent
	return null


# Przełącza widoczność przycisków kierunkowych venta - wywoływane lokalnie w _rollback_tick
@rpc("any_peer", "call_local", "reliable")
func vent_toggle_dir_bttns(is_on:bool):
	var vent = get_closest_vent()
	if vent != null:
		vent.change_dir_bttns_visibility(is_on)


func summon_window():
	minigame_container.visible = true
	var minigame_viewport = minigame_container.get_node("MinigameViewport")
	minigame_viewport.add_child(minigame.instantiate())
	minigame_instance = minigame_viewport.get_child(0)
	var x_scale = minigame_viewport.size.x / get_viewport_rect().size.x
	var y_scale = minigame_viewport.size.y / get_viewport_rect().size.y
	minigame_instance.scale = Vector2(x_scale, y_scale)
	use_button.visible = false
	use_button.disabled = true
	GameManager.set_input_status(false)
	minigame_instance.minigame_end.connect(end_minigame)
	close_button.visible = true
	minigame_background.visible = true

func end_minigame():
	minigame_instance.queue_free()
	minigame_container.visible = false
	GameManager.set_input_status(true)
	close_button.visible = false
	TaskManager.mark_task_as_complete_player()
	minigame_background.visible = false
	
func close_minigame():
	if minigame_instance != null:
		minigame_instance.queue_free()
		minigame_container.visible = false
		GameManager.set_input_status(true)
		close_button.visible = false
		show_use_button(name.to_int(), minigame)
		minigame_background.visible = false
