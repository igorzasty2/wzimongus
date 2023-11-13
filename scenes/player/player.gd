# Definiuje postać gracza.
extends CharacterBody2D

@export var id : int
@export var nickname : String

const SPEED = 300.0

func _ready():
	# Ustawia autorytet gracza na jego id w celu jego identyfikacji w systemie multiplayer.
	$InputSynchronizer.set_multiplayer_authority(id)
	# Ustawia etykietę pseudonimu gracza.
	$NicknameLabel.text = nickname


@onready var input = $InputSynchronizer

func _physics_process(delta):
	# Sprawdza, czy gracz jest autoryzowany w systemie multiplayer.
	# Pobiera pionowe wejście gracza i odpowiednio ustawia pionową prędkość.
	var direction = Vector2(input.direction.x, input.direction.y)
	if direction:
		velocity.x = direction.x * SPEED
		velocity.y = direction.y * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	# Porusza graczem i obsługuje kolizje.
	move_and_slide()
