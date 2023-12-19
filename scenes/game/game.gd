extends Control

@onready var connecting = $Connecting
@onready var error = $Error
@onready var error_pop_up = $Error/ErrorPopUp
@onready var maps = $Maps

func _ready():
	GameManager.registered_successfully.connect(_on_registered_successfully)
	GameManager.game_started.connect(_on_game_started)
	GameManager.game_ended.connect(_on_game_ended)
	GameManager.error_occured.connect(_on_error_occured)
	error_pop_up.left_pressed.connect(_on_error_pop_up_closed)

func _on_registered_successfully():
	connecting.hide()
	_change_map.call_deferred(load("res://scenes/maps/lobby/lobby.tscn"))

func _on_game_started():
	_change_map.call_deferred(load("res://scenes/maps/main_map/main_map.tscn"))

func _on_game_ended():
	if !error.visible:
		get_tree().change_scene_to_file("res://scenes/ui/start_menu/start_menu.tscn")

func _on_error_occured(message: String):
	if !error.visible:
		connecting.hide()
		_delete_map()
		error_pop_up.set_information(message)
		error.show()

func _on_error_pop_up_closed():
	get_tree().change_scene_to_file("res://scenes/ui/start_menu/start_menu.tscn")

## Zmienia wyświetlaną globalnie mapę.
func _change_map(scene: PackedScene):
	_delete_map()
	maps.add_child(scene.instantiate())

## Usuwa aktualną mapę.
func _delete_map():
	for i in maps.get_children():
		maps.remove_child(i)
		i.queue_free()
