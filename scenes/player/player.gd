extends CharacterBody2D

@export var speed = 600.0
var last_direction_x: float = -1

@onready var input = $Input
@onready var rollback_synchronizer = $RollbackSynchronizer
@onready var username_label = $UsernameLabel
@onready var animation_tree = $Skins/AnimationTree
@onready var player_sprite = $Skins/PlayerSprite

# zmienne do funkcji zabijania
var in_range_color = [180, 0, 0, 255]
var out_of_range_color = [0, 0, 0, 0]
var potential_victims : Array

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

	_toggle_highlight($".".name.to_int(),false)
	
	GameManager.player_killed.connect(_on_killed_player)

func _process(_delta):
	# Aktualizuje parametry animacji postaci.
	var direction = input.direction.normalized()
	
	_update_animation_parameters(direction)

	closest_player()
	
	if Input.is_action_just_pressed("ui_home"):
		var victim = closest_player()
		if victim:
			print("zabij: "+str(victim))
			GameManager.kill(victim)

func _rollback_tick(_delta, _tick, _is_fresh):
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

## Włącza i wyłącza podświetlenie możliwości zabicia gracza
func _toggle_highlight(player: int, is_on: bool) -> void:
	if is_on:
		get_parent().get_node(str(player) + "/Skins/PlayerSprite").material.set_shader_parameter('line_color', in_range_color)
	else:
		get_parent().get_node(str(player) + "/Skins/PlayerSprite").material.set_shader_parameter('line_color', out_of_range_color)

func _update_highlight(player: int) -> void:
		var all_players = GameManager.get_registered_players().keys()
		
		for i in all_players:
			if player != null and i == player:
				_toggle_highlight(i,true)
			else:
				_toggle_highlight(i,false)

## Zwraca id: int najbliższego gracza
func closest_player():
	
	if GameManager.get_current_player_key("is_lecturer"):
		var all_players: Array = GameManager.get_registered_players().keys()
		var me = GameManager.get_current_player_id()
		
		all_players.erase(me)
		
		for i in all_players:
			if GameManager.get_registered_player_key(i,"is_lecturer") or GameManager.get_registered_player_key(i,"is_dead"):
				all_players.erase(i)
		
		var kill_radius = 260
		if all_players.size() > 0:
			var my_position: Vector2 = get_parent().get_node(str(GameManager.get_current_player_id())).global_position
			var curr_closest = null
			var curr_closest_dist = kill_radius**2 + 1
			for i in range(all_players.size()):
				var temp_position: Vector2 = get_parent().get_node(str(all_players[i])).global_position
				var temp_dist = my_position.distance_squared_to(temp_position)
				if(temp_dist < curr_closest_dist):
					curr_closest = all_players[i]
					curr_closest_dist = temp_dist
			if curr_closest_dist < (kill_radius**2):
				_update_highlight(curr_closest)
				return curr_closest
			_update_highlight(0)
		_update_highlight(0)


func _on_killed_player(victim: int):
	if GameManager.get_registered_player_key(victim,"is_dead"):
		get_parent().get_node(str(victim)).visible = false
		print(str(victim)+" dead")
		
		var dead_body = preload("res://scenes/player/assets/dead_body.tscn").instantiate()
		dead_body.get_node("DeadBodySprite").texture = load("res://icon.svg")
		dead_body.get_node("DeadBodyLabel").text = str(victim)+" dead body"
		dead_body.global_position = get_parent().get_node(str(victim)).global_position
		
		get_parent().add_child(dead_body)
		print("dead body dodane na pozycji: "+str(dead_body.global_position))
