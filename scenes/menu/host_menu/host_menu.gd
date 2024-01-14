extends Control

@onready var lobby_name_input = $InputsContainer/LobbyNameContainer/LobbyNameInput
@onready var username_input = $InputsContainer/UsernameContainer/UsernameInput
@onready var port_input = $InputsContainer/PortContainer/PortInput


func _on_host_button_pressed():
	GameManagerSingleton.set_current_player_value("username", username_input.text)

	get_tree().change_scene_to_file("res://scenes/game/game.tscn")

	GameManagerSingleton.create_lobby.call_deferred(lobby_name_input.text, port_input.text.to_int())


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/menu/play_menu/play_menu.tscn")
