extends CharacterBody2D

# Ostatni kierunek ruchu postaci na osi X.
var last_direction_x: float = 1
# Stała określająca prędkość postaci.
const SPEED = 300.0

@export var input: InputSynchronizer

@onready var animation_tree = $Skins/AltAnimationTree


func _ready():
	if input == null:
		input = $Input

	await get_tree().process_frame

	$RollbackSynchronizer.process_settings()

	# Ustawia nazwę użytkownika w etykiecie.
	$UsernameLabel.text = GameManager.get_registered_player_key(name.to_int(), "username")

	# Aktywuje drzewo animacji postaci.
	animation_tree.active = true


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
