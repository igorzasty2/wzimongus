## Klasa odpowiedzialna za zarządzanie sceną gry.
class_name Game
extends Control


@onready var _connecting = $Connecting
@onready var _maps = $Maps
@onready var _error = $Error
@onready var _error_pop_up = $Error/ErrorPopUp
@onready var _pause_menu = $PauseMenu


func _ready():
	GameManagerSingleton.registered_successfully.connect(_on_registered_successfully)
	GameManagerSingleton.game_started.connect(_on_game_started)
	GameManagerSingleton.game_ended.connect(_on_game_ended)
	GameManagerSingleton.error_occured.connect(_on_error_occured)
	GameManagerSingleton.winner_determined.connect(_on_winner_determined)
	_error_pop_up.middle_pressed.connect(_on_error_pop_up_closed)

	GameManagerSingleton.is_game_scene_loaded = true


func _on_registered_successfully():
	_change_map.call_deferred(load("res://scenes/game/maps/lobby/lobby.tscn"))


## Wysyła wszystkim graczom informacje o roli która wygrała.
func _on_winner_determined(winning_role: GameManagerSingleton.Role, is_lecturer: bool):
	display_winner.rpc(winning_role)


@rpc("call_local", "reliable")
## Wyświetla ekran zakończenia gry.
func display_winner(winning_role: GameManagerSingleton.Role):
	var ending_scene = preload("res://scenes/game/end_screen/end_screen.tscn").instantiate()
	ending_scene.set_winning_role(winning_role)
	get_tree().get_root().add_child(ending_scene)

	GameManagerSingleton.reset_game()

	_change_map.call_deferred(load("res://scenes/game/maps/lobby/lobby.tscn"))


func _on_game_started():
	_change_map.call_deferred(load("res://scenes/game/maps/main_map/main_map.tscn"))


func _on_game_ended():
	if !_error.visible:
		get_tree().change_scene_to_file("res://scenes/menu/start_menu/start_menu.tscn")


func _on_error_occured(message: String):
	if !_error.visible:
		_pause_menu.queue_free()
		
		_connecting.hide()
		_delete_map()
		_error_pop_up.set_information(message)
		_error.show()


func _on_error_pop_up_closed():
	get_tree().change_scene_to_file("res://scenes/menu/start_menu/start_menu.tscn")


## Zmienia wyświetlaną globalnie mapę.
func _change_map(scene: PackedScene):
	_connecting.show()
	_delete_map()

	var scene_instantiated = scene.instantiate()
	scene_instantiated.connect("load_finished", _on_load_finished)
	_maps.add_child(scene_instantiated)


## Usuwa aktualną mapę.
func _delete_map():
	for i in _maps.get_children():
		i.disconnect("load_finished", _on_load_finished)
		_maps.remove_child(i)
		i.queue_free()


func _on_load_finished():
	_connecting.hide()
