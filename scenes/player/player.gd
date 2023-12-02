# Definiuje postać gracza.

extends CharacterBody2D

@export var id : int
@export var username : String

var direction : Vector2 = Vector2.ZERO
var last_direction_x : float
const SPEED = 300.0

@onready var input = $InputSynchronizer
@onready var animation_tree = $Skins/AltAnimationTree


func _ready():
	# Ustawia autorytet gracza na jego id w celu jego identyfikacji w systemie multiplayer.
	input.set_multiplayer_authority(id)
	# Wyłącza synchronizację wejścia gracza, jeśli nie jest on obecnym graczem.
	input.set_process(input.get_multiplayer_authority() == multiplayer.get_unique_id())
	# Ustawia etykietę pseudonimu gracza.
	$UsernameLabel.text = username
	animation_tree.active = true
	last_direction_x = 1

func  _process(_delta):
	update_animation_parameters()

func _physics_process(_delta):
	# Pobiera pionowe i poziome wejście gracza, i odpowiednio ustawia pionową oraz poziomą prędkość.
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
	
func update_animation_parameters():
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

# Wyłącza ruch gracza gdy jest pauza, włącza gdy nie ma pauzy
func _on_pause_menu_paused(is_paused):
	if input.get_multiplayer_authority() == multiplayer.get_unique_id():
		input.set_process(!is_paused)

	input.direction = Vector2.ZERO
