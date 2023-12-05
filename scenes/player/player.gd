extends CharacterBody2D

# Kierunek ruchu postaci.
var direction : Vector2 = Vector2.ZERO
# Ostatni kierunek ruchu postaci na osi X.
var last_direction_x : float
# Stała określająca prędkość postaci.
const SPEED = 300.0

@export var input: InputSynchronizer

@onready var animation_tree = $Skins/AltAnimationTree


func _ready():
	if input == null:
		input = $Input

	# Aktywuje przetwarzanie wejścia dla sterowanego przez gracza węzła.
	if input.get_multiplayer_authority() == multiplayer.get_unique_id():
		GameManager.input_status_changed.connect(_on_input_status_changed)
	else:
		input.set_process(false)

	# Ustawia nazwę użytkownika w etykiecie.
	$UsernameLabel.text = GameManager.get_registered_player_key(name.to_int(), "username")

	# Aktywuje drzewo animacji postaci.
	animation_tree.active = true

	# Inicjalizuje początkowy kierunek postaci.
	last_direction_x = 1

	await get_tree().process_frame
	$RollbackSynchronizer.process_settings()


func _process(_delta):
	# Aktualizuje parametry animacji.
	_update_animation_parameters()


func _rollback_tick(delta, _tick, _is_fresh):
	# Oblicza kierunek ruchu na podstawie wejścia użytkownika.
	direction = Vector2(input.direction.x, input.direction.y)
	direction = direction.normalized()

	# Ustawia prędkość postaci zgodnie z obliczonym kierunkiem.
	if direction:
		velocity.x = direction.x * SPEED
		velocity.y = direction.y * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	# Zapisuje ostatni kierunek ruchu postaci.
	if direction.x != 0:
		last_direction_x = direction.x

	# Porusza postacią i obsługuje kolizje.
	velocity *= NetworkTime.physics_factor
	move_and_slide()
	velocity /= NetworkTime.physics_factor


# Aktualizuje parametry animacji postaci.
func _update_animation_parameters():
	# Ustawia parametry animacji w zależności od stanu ruchu.
	if velocity == Vector2.ZERO:
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false
	else:
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/is_moving"] = true
		if direction.x != 0:
			animation_tree["parameters/idle/blend_position"] = direction
			animation_tree["parameters/walk/blend_position"] = direction
		if direction.x == 0:
			animation_tree["parameters/idle/blend_position"] = Vector2(last_direction_x ,direction.y)
			animation_tree["parameters/walk/blend_position"] = Vector2(last_direction_x ,direction.y)


# Ustawia stan przetwarzania wejścia postaci.
func _on_input_status_changed(state: bool):
	input.set_process(state)
	input.direction = Vector2.ZERO
