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
	
	
	toggle_highlight($".",false)

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
func toggle_highlight(player: Node2D, is_on: bool) -> void:
	if is_on:
		get_parent().get_node(str(player.name) + "/Skins/PlayerSprite").material.set_shader_parameter('line_color', in_range_color)
	else:
		get_parent().get_node(str(player.name) + "/Skins/PlayerSprite").material.set_shader_parameter('line_color', out_of_range_color)

## Aktywuje się przy wejściu drugiego gracza do naszego KillArea
func _on_kill_area_body_entered(body: Node2D) -> void:
	if _is_valid(body):
		print(str(GameManager.get_current_player_id())+": "+ body.name + " is valid")
		toggle_highlight(body,true)

## Aktywuje się przy wyjściu drugiego gracza do naszego KillArea
func _on_kill_area_body_exited(body: Node2D) -> void:
	toggle_highlight(body,false)

## Sprawdza, czy my jesteśmy prowadzącym, a "body" studentem i oboje żyjemy
## Jeśli tak, zwraca true, w przeciwnym wypadku false
func _is_valid(body: Node2D) -> bool:
	var me: int = $".".name.to_int()
	var other: int = body.name.to_int()
	var lecturer_me = GameManager.get_registered_player_key(me,"is_lecturer")
	var lecturer_other = GameManager.get_registered_player_key(other,"is_lecturer")
	var dead_me = GameManager.get_registered_player_key(me,"is_dead")
	var dead_other = GameManager.get_registered_player_key(other,"is_dead")
	
	if lecturer_me and !dead_me and !lecturer_other and !dead_other:
		return true
	return false
