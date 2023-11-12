# Definiuje postać gracza.
extends CharacterBody2D

@export var id : int
@export var nickname : String

const SPEED = 300.0

@onready var synchronizer = $MultiplayerSynchronizer

func _ready():
	# Ustawia autorytet gracza na jego id w celu jego identyfikacji w systemie multiplayer.
	synchronizer.set_multiplayer_authority(id)
	# Ustawia etykietę pseudonimu gracza.
	$NicknameLabel.text = nickname


func _physics_process(delta):
	# Sprawdza, czy gracz jest autoryzowany w systemie multiplayer.
	if synchronizer.is_multiplayer_authority():
		# Pobiera pionowe wejście gracza i odpowiednio ustawia pionową prędkość.
		var direction_y = Input.get_axis("ui_up", "ui_down")
		if direction_y:
			velocity.y = direction_y * SPEED
		else:
			velocity.y = move_toward(velocity.y, 0, SPEED)
		
		# Pobiera poziome wejście gracza i odpowiednio ustawia poziomą prędkość.
		var direction_x = Input.get_axis("ui_left", "ui_right")
		if direction_x:
			velocity.x = direction_x * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
		# Porusza graczem i obsługuje kolizje.
		move_and_slide()
