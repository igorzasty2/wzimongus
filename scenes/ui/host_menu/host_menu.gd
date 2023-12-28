extends Control

@onready var lobby_name_input = $InputsContainer/LobbyNameContainer/LobbyNameInput
@onready var username_input = $InputsContainer/UsernameContainer/UsernameInput
@onready var port_input = $InputsContainer/PortContainer/PortInput


func _on_host_button_pressed():
	GameManager.set_player_key("username", username_input.text)

	get_tree().change_scene_to_file("res://scenes/game/game.tscn")

	GameManager.create_lobby.call_deferred(lobby_name_input.text, port_input.text.to_int())


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/play_menu/play_menu.tscn")
