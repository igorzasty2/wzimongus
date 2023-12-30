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
	
	_toggle_highlight($".",false)

func _process(_delta):
	# Aktualizuje parametry animacji postaci.
	var direction = input.direction.normalized()
	_update_animation_parameters(direction)
	#_update_positions_in_potential_victims()
	#_update_highlight()

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
func _toggle_highlight(player: Node2D, is_on: bool) -> void:
	if is_on:
		get_parent().get_node(str(player.name) + "/Skins/PlayerSprite").material.set_shader_parameter('line_color', in_range_color)
	else:
		get_parent().get_node(str(player.name) + "/Skins/PlayerSprite").material.set_shader_parameter('line_color', out_of_range_color)

func _update_highlight() -> void:
	var id: int = _is_closest_to_me()
	var available_players = GameManager.get_registered_players().keys()
	for i in available_players:
		if id == i:
			get_parent().get_node(str(i)+ "/Skins/PlayerSprite").material.set_shader_parameter('line_color', in_range_color)
		else:
			get_parent().get_node(str(i)+ "/Skins/PlayerSprite").material.set_shader_parameter('line_color', out_of_range_color)


## Aktywuje się przy wejściu drugiego gracza do naszego KillArea
func _on_kill_area_body_entered(body: Node2D) -> void:
	var other: int = body.name.to_int()
	var lecturer_me = GameManager.get_current_player_key("is_lecturer")
	var lecturer_other = GameManager.get_registered_player_key(other,"is_lecturer")
	var dead_me = GameManager.get_current_player_key("is_dead")
	var dead_other = GameManager.get_registered_player_key(other,"is_dead")
	
	if lecturer_me and !dead_me:
		if !lecturer_other and !dead_other:
			potential_victims.append(body.name.to_int()) 
			potential_victims.append(Vector2(get_parent().get_node(str(body.name)).position))

## Aktywuje się przy wyjściu drugiego gracza do naszego KillArea
func _on_kill_area_body_exited(body: Node2D) -> void:
	if potential_victims.size() > 0:
		for i in range(potential_victims.size()):
			if typeof(potential_victims[i]) == TYPE_INT and potential_victims[i] == body.name.to_int():
				potential_victims.remove_at(i+1)
				potential_victims.erase(body.name.to_int())
				return

## Zwraca id: int najbliższego gracza
func _is_closest_to_me() -> int:
	# distances[playerid: int][odległość: float]
	var distances = []
	var minimum: float = $KillArea/KillCollisionShape.shape.radius
	if potential_victims.size() == 0: return 0
	
	for i in range(potential_victims.size()):
		# odległość potential_victims[i] od nas
		var temp: float = sqrt(pow(potential_victims[i][0].x-position.x,2)+pow(potential_victims[i][0].y-position.y,2))
		
		distances.append(i)
		distances[i].append([temp])
		
		minimum = min(minimum, distances[i][0])
		
	for i in range(distances.size()):
		if distances[i][0] == minimum: 
			return distances[i]
	return 0

func _update_positions_in_potential_victims() -> void:
	for i in potential_victims:
		i[0] = get_parent().get_node(str(i)).position
