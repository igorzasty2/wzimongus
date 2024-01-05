extends Area2D
## Klasa będąca reprezentacją punktu interakcji z kamerami

## Scena systemu kamer do wyświetlenia
@onready var cameras_scene : PackedScene = load("res://scenes/ui/camera_system/camera_system.tscn")

## Referencja do okna w którym wyświetlony zostanie system kamer
@onready var minigame_menu = get_parent().get_node("MinigameMenu")

## Informacja czy jest gracz jest w zasięgu interakcji
var _is_player_inside : bool = false

## Wyświetla przycisk uruchomienia systemu kamer
func _on_body_entered(body):
	if body.name.to_int() == multiplayer.get_unique_id():
		_is_player_inside = true
		minigame_menu.show_use_button(cameras_scene)

## Ukrywa przycisk uruchomienia systemu kamer
func _on_body_exited(body):
	if body.name.to_int() == multiplayer.get_unique_id():
		_is_player_inside = false
		minigame_menu.hide_use_button()
