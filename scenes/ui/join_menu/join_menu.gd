extends Control

@onready var username_input = $InputsContainer/UsernameContainer/UsernameInput
@onready var address_input = $InputsContainer/AddressContainer/AddressInput
@onready var port_input = $InputsContainer/PortContainer/PortInput

func _on_join_button_button_down():
	GameManager.set_player_key("username", username_input.text)

	get_tree().change_scene_to_file("res://scenes/game/game.tscn")

	GameManager.join_game.call_deferred(address_input.text, port_input.text.to_int())
