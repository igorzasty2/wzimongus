extends CharacterBody2D

var direction : Vector2 = Vector2.ZERO
var last_direction_x : float
const SPEED = 300.0

@onready var input = $InputSynchronizer
@onready var animation_tree = $Skins/AltAnimationTree


func _ready():
	# Ustawia autorytet gracza na jego id w celu identyfikacji jego wejścia.
	input.set_multiplayer_authority(name.to_int())

	# Jeśli gracz może sterować swoją postacią, to ustawia jego wejście na aktywne.
	if input.get_multiplayer_authority() == multiplayer.get_unique_id():
		GameManager.input_state_changed.connect(_on_input_state_changed)
	else:
		input.set_process(false)

	# Ustawia etykietę z nazwą gracza.
	$UsernameLabel.text = GameManager.get_registered_player_info(name.to_int(), "username")

	# Ustawia animację gracza.
	animation_tree.active = true

	# Ustawia początkowy kierunek wzroku gracza.
	last_direction_x = 1


func _process(_delta):
	_update_animation_parameters()


func _physics_process(_delta):
	# Pobiera wejście gracza i ustawia odpowiedni kierunek ruchu.
	direction = Vector2(input.direction.x, input.direction.y)
	direction = direction.normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.y = direction.y * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	# Zapamiętuje ostatni kierunek wzroku postaci
	if direction.x != 0:
		last_direction_x = direction.x

	# Porusza graczem i obsługuje kolizje.
	move_and_slide()


# Aktualizuje parametry animacji.
func _update_animation_parameters():
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


# Ustawia stan wejścia gracza.
func _on_input_state_changed(state: bool):
	input.set_process(state)
	input.direction = Vector2.ZERO
