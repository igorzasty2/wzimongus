extends CharacterBody2D

# Ostatni kierunek ruchu postaci na osi X.
var last_direction_x: float = 1
# Stała określająca prędkość postaci.
const SPEED = 600.0
var minigame: PackedScene
var minigame_instance:Node2D

# Zmienne do obsługi ventów
var teleport_position = Vector2.ZERO 
var is_impostor = GameManager._current_player["impostor"]

@export var input: InputSynchronizer

@onready var animation_tree = $Skins/AltAnimationTree
@onready var camera = get_parent().get_parent().get_node("Camera")
@onready var minigame_container = get_parent().get_parent().get_node("Camera").get_node("MinigameContainer")
@onready var use_button:TextureButton = get_parent().get_parent().get_node("Camera").get_node("UseButton")
@onready var close_button:TextureButton = get_parent().get_parent().get_node("Camera").get_node("CloseButton")
@onready var minigame_background:ColorRect = get_parent().get_parent().get_node("Camera").get_node("MinigameBackground")


func _ready():
	if input == null:
		input = $Input

	await get_tree().process_frame

	$RollbackSynchronizer.process_settings()

	# Ustawia nazwę użytkownika w etykiecie.
	$UsernameLabel.text = GameManager.get_registered_player_key(name.to_int(), "username")

	# Aktywuje drzewo animacji postaci.
	animation_tree.active = true
	last_direction_x = 1
	use_button.pressed.connect(_on_use_button_pressed)
	close_button.pressed.connect(close_minigame)


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
	
	# Odpowiada za przeniesienie gracza do innego venta
	if teleport_position != Vector2.ZERO :#&& is_impostor:
		position = teleport_position
		teleport_position = Vector2.ZERO


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

func show_use_button(id, minigame):
	if id == multiplayer.get_unique_id():
		self.minigame = minigame
		use_button.visible = true
		use_button.disabled = false


func hide_use_button(id):
	if id == multiplayer.get_unique_id():
		minigame = null
		use_button.visible = false
		use_button.disabled = true


func _on_use_button_pressed():
	if minigame != null && minigame_container.get_node("MinigameViewport").get_child_count() == 0:
		summon_window()


func _input(event):
	if (
		event.is_action_pressed("interact") 
		&& minigame != null && !use_button.disabled 
		&& minigame_container.get_node("MinigameViewport").get_child_count() == 0
		&& !GameManager.get_current_game_key("paused")
	):
		summon_window()

func summon_window():
	minigame_container.visible = true
	var minigame_viewport = minigame_container.get_node("MinigameViewport")
	minigame_viewport.add_child(minigame.instantiate())
	minigame_instance = minigame_viewport.get_child(0)
	var x_scale = minigame_viewport.size.x / get_viewport_rect().size.x
	var y_scale = minigame_viewport.size.y / get_viewport_rect().size.y
	minigame_instance.scale = Vector2(x_scale, y_scale)
	use_button.visible = false
	use_button.disabled = true
	GameManager.set_input_status(false)
	minigame_instance.minigame_end.connect(end_minigame)
	close_button.visible = true
	minigame_background.visible = true

func end_minigame():
	minigame_instance.queue_free()
	minigame_container.visible = false
	GameManager.set_input_status(true)
	close_button.visible = false
	TaskManager.mark_task_as_complete_player()
	minigame_background.visible = false
	
func close_minigame():
	if minigame_instance != null:
		minigame_instance.queue_free()
		minigame_container.visible = false
		GameManager.set_input_status(true)
		close_button.visible = false
		show_use_button(name.to_int(), minigame)
		minigame_background.visible = false
