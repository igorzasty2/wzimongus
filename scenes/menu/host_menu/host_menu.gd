## Klasa odpowiedzialna za obsługę menu hosta.
class_name HostMenu
extends Control


@onready var _lobby_name_input = $InputsContainer/LobbyNameContainer/LobbyNameInput
@onready var _username_input = $InputsContainer/UsernameContainer/UsernameInput
@onready var _port_input = $InputsContainer/PortContainer/PortInput


func _on_host_button_pressed():
	GameManagerSingleton.set_current_player_value("username", _username_input.text)

	GameManagerSingleton.create_lobby.call_deferred(_lobby_name_input.text, _port_input.text.to_int())

	get_tree().change_scene_to_file("res://scenes/game/game.tscn")


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/menu/play_menu/play_menu.tscn")
