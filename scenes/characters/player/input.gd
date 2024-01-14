## Synchronizer wejścia gracza z serwerem.
class_name InputSynchronizer
extends Node


## Wektor kierunku poruszania się gracza.
@export var direction: Vector2 = Vector2.ZERO

## Czy gracz jest sterowany automatycznie.
var is_walking_to_destination: bool = false
## Pozycja docelowa do której gracz się automatycznie porusza.
var destination_position: Vector2 = Vector2.ZERO

## Czy synchronizacja wejścia jest wyłączona.
var _is_disabled: bool = false

## Referencja do gracza.
@onready var _player: Player = get_parent()


func _ready():
	NetworkTime.before_tick_loop.connect(_gather)

	# Oczekuje jedną klatkę, aby autorytet inputu był na pewno ustawiony.
	await get_tree().process_frame

	if is_multiplayer_authority():
		GameManagerSingleton.input_status_changed.connect(_on_input_status_changed)
		GameManagerSingleton.emit_input_status()


func _gather():
	if !is_multiplayer_authority():
		return

	if is_walking_to_destination:
		direction = (destination_position - _player.global_position).normalized()
		return

	if _is_disabled:
		direction = Vector2.ZERO
		return

	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")


func _on_input_status_changed(state: bool):
	_is_disabled = !state
