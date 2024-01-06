## Główna klasa gracza.
class_name Player
extends CharacterBody2D

## Prędkość poruszania się.
@export var walking_speed: float = 600.0
## Ostatni kierunek poziomego ruchu gracza.
var last_direction_x: float = -1

## Referencja do wejścia gracza.
@onready var input = $Input
## Referencja do synchronizatora rollbacku.
@onready var rollback_synchronizer = $RollbackSynchronizer
## Referencja do etykiety z nazwą gracza.
@onready var username_label = $UsernameLabel
## Referencja do drzewa animacji postaci.
@onready var animation_tree = $Skins/AnimationTree
## Referencja do sprite'a postaci.
@onready var player_sprite = $Skins/PlayerSprite
## Referencja do node'a postaci.
@onready var player_node = $"."

## Kolor gracza do zabicia
var in_range_color = [180, 0, 0, 255]
## Kolor gracza, którego nie możemy zabić
var out_of_range_color = [0, 0, 0, 0]
## Kolor nicku martwego gracza
var dead_username_color = Color.DARK_GOLDENROD
## Przechowuje informację o możliwości użycia funkcji zabicia 
var can_kill_cooldown: bool = false


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
	
	# Wyłącza podświetlenie aktualnego gracza
	_toggle_highlight(player_node.name.to_int(),false)
	
	# Łączy sygnał zabicia postaci z funkcją _on_killed_player
	GameManager.player_killed.connect(_on_killed_player)
	
	# Jeśli gracz jest impostorem to ustawia początkową możliwość zabicia na true
	if GameManager.get_current_player_key("is_lecturer"):
		can_kill_cooldown = true

func _process(_delta):
	var direction = input.direction.normalized()
	
	# Aktualizuje parametry animacji postaci.
	_update_animation_parameters(direction)

func _rollback_tick(_delta, _tick, _is_fresh):
	# Oblicza kierunek ruchu na podstawie wejścia użytkownika.
	velocity = input.direction.normalized() * walking_speed

	# Porusza postacią i obsługuje kolizje.
	velocity *= NetworkTime.physics_factor
	move_and_slide()
	velocity /= NetworkTime.physics_factor
	
	# Podświetla najbliższego gracza jako potencjalną ofiarę do oblania jeśli jestem impostorem,
	# żyje i cooldown na funcji zabij nie jest aktywny.
	if GameManager.get_current_player_key("is_lecturer"):
		if !GameManager.get_current_player_key("is_dead"):
			if can_kill_cooldown:
				_update_highlight(closest_player(GameManager.get_current_player_id()))
			else:
				_update_highlight(0)

## Sprawdza, czy nie naciśnięto fail button. Jeśli tak to sprawdza, czy jesteśmy lecturerem
## i prosi serwer o oblanie najbliższego gracza w promieniu oblania.
func _input(event):
	if event.is_action("fail") and event.is_pressed() and not event.is_echo():
		if name.to_int() == GameManager.get_current_player_id():
			if GameManager.get_registered_player_key(name.to_int(),"is_lecturer"):
				if can_kill_cooldown:
					var victim = closest_player(GameManager.get_current_player_id())
					if victim:
						can_kill_cooldown = false
						GameManager.kill(victim)
						var timer = Timer.new()
						timer.timeout.connect(_on_timer_timeout)
						timer.one_shot = true
						timer.wait_time = GameManager.get_server_settings()["kill_cooldown"]
						add_child(timer)
						timer.start()

## Aktualizuje parametry animacji postaci.
func _update_animation_parameters(direction) -> void:
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

## Włącza i wyłącza podświetlenie możliwości zabicia gracza
func _toggle_highlight(player: int, is_on: bool) -> void:
	var player_material = get_parent().get_node(str(player) + "/Skins/PlayerSprite").material
	if player_material:
		if is_on:
			player_material.set_shader_parameter('color', in_range_color)
		else:
			player_material.set_shader_parameter('color', out_of_range_color)

func _update_highlight(player: int) -> void:
		var all_players = GameManager.get_registered_players().keys()
		all_players.erase(GameManager.get_current_player_id())
		
		for i in all_players:
			if player != null and i == player:
				_toggle_highlight(i,true)
			else:
				_toggle_highlight(i,false)

## Zwraca id: int najbliższego gracza do "to_who", który nie jest impostorem i żyje
func closest_player(to_who: int) -> int:
	## Tablica graczy do przeszukiwania najbliższego gracza
	var players: Array = GameManager.get_registered_players().keys()
	players.erase(to_who)
	
	for i in players:
		if GameManager.get_registered_player_key(i,"is_lecturer") or GameManager.get_registered_player_key(i,"is_dead"):
			players.erase(i)
	
	if players.size() > 0:
		## Pobiera promień zabicia z serwera
		var kill_radius = GameManager.get_server_settings()["kill_radius"]
		
		## Przechowuje wektor pozycji gracza, względem którego szukamy najbliższego gracza
		var my_position: Vector2 = get_tree().root.get_node("Game/Maps/MainMap/Players/"+str(to_who)).global_position
		
		## Przechowuje node najbliższego gracza
		var curr_closest = null
		
		## Przechowuje odległość najbliższego gracza od pozycji 'my_position'
		var curr_closest_dist = kill_radius**2 + 1
		
		for i in range(players.size()):
			## Pozycja gracza tymczasowego
			var temp_position: Vector2 = get_tree().root.get_node("Game/Maps/MainMap/Players/"+str(players[i])).global_position
			## Dystans gracza tymczasowego od pozycji 'my_position'
			var temp_dist = my_position.distance_squared_to(temp_position)
			
			if(temp_dist < curr_closest_dist):
				curr_closest = players[i]
				curr_closest_dist = temp_dist
				
		if curr_closest_dist < (kill_radius**2):
			return curr_closest
		return 0
	return 0

func _on_killed_player(victim: int) -> void:
	if GameManager.get_registered_player_key(victim,"is_dead"):
		_update_dead_player(victim)
		
		if GameManager.get_current_player_id() != victim:
			get_parent().get_node(str(victim)).visible = false
	
	if GameManager.get_current_player_key("is_dead"):
		for i in GameManager.get_registered_players().keys():
			get_parent().get_node(str(i)).visible = true
	
	var dead_body = preload("res://scenes/player/assets/dead_body.tscn").instantiate()
	get_parent().add_child(dead_body)
	dead_body.set_dead_player(victim)
	dead_body.get_node("DeadBodyLabel").text = GameManager.get_registered_player_key(victim,"username")+" dead body"

func _on_timer_timeout() -> void:
	if GameManager.get_current_player_id() == name.to_int():
		if GameManager.get_current_player_key("is_lecturer"):
			can_kill_cooldown = true
			for i in range(player_node.get_child_count()):
				var child: Node = player_node.get_child(i)
				if child.is_class("Timer"):
					child.queue_free()
					return

func _update_dead_player(victim: int):
	var victim_node: CharacterBody2D = get_tree().root.get_node("Game/Maps/MainMap/Players/"+str(victim))
	victim_node.get_node("UsernameLabel").add_theme_color_override("font_color", dead_username_color)
	victim_node.get_node("Skins/PlayerSprite").material = null
	victim_node.get_node("Skins/PlayerSprite").modulate = Color(1,1,1,0.35)
	victim_node.collision_mask = 0
