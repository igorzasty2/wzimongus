extends Control

@onready var connecting = $Connecting
@onready var maps = $Maps
@onready var error = $Error
@onready var error_pop_up = $Error/ErrorPopUp


func _ready():
	GameManager.registered_successfully.connect(_on_registered_successfully)
	GameManager.game_started.connect(_on_game_started)
	GameManager.game_ended.connect(_on_game_ended)
	GameManager.error_occured.connect(_on_error_occured)
	GameManager.winner_determined.connect(_on_winner_determined)
	error_pop_up.middle_pressed.connect(_on_error_pop_up_closed)


func _on_registered_successfully():
	_change_map.call_deferred(load("res://scenes/game/maps/lobby/lobby.tscn"))


## Wysyła wszystkim graczom informacje o roli która wygrała.
func _on_winner_determined(winning_role: GameManager.Role):
	display_winner.rpc(winning_role)


@rpc("call_local", "reliable")
## Wyświetla ekran zakończenia gry.
func display_winner(winning_role: GameManager.Role):
	var ending_scene = preload('res://scenes/game/end_screen/end_screen.tscn').instantiate()
	ending_scene.set_winning_role(winning_role)
	get_tree().get_root().add_child(ending_scene)

	GameManager.reset_game()

	_change_map.call_deferred(load("res://scenes/game/maps/lobby/lobby.tscn"))


func _on_game_started():
	_change_map.call_deferred(load("res://scenes/game/maps/main_map/main_map.tscn"))


func _on_game_ended():
	if !error.visible:
		get_tree().change_scene_to_file("res://scenes/menu/start_menu/start_menu.tscn")


func _on_error_occured(message: String):
	if !error.visible:
		$PauseMenu.queue_free()
		
		connecting.hide()
		_delete_map()
		error_pop_up.set_information(message)
		error.show()


func _on_error_pop_up_closed():
	get_tree().change_scene_to_file("res://scenes/menu/start_menu/start_menu.tscn")


## Zmienia wyświetlaną globalnie mapę.
func _change_map(scene: PackedScene):
	connecting.show()
	_delete_map()
	var scene_instantiated = scene.instantiate()
	scene_instantiated.connect("load_finished", _on_load_finished)
	maps.add_child(scene_instantiated)


## Usuwa aktualną mapę.
func _delete_map():
	for i in maps.get_children():
		i.disconnect("load_finished", _on_load_finished)
		maps.remove_child(i)
		i.queue_free()


func _on_load_finished():
	connecting.hide()
