extends Control


func _on_join_button_button_down():
	var username = $InputsContainer/UsernameContainer/UsernameInput.text
	var address = $InputsContainer/AddressContainer/AddressInput.text
	var port = $InputsContainer/PortContainer/PortInput.text.to_int()

	GameManager.set_player_key("username", username)
	GameManager.join_game(address, port)

	get_tree().change_scene_to_file("res://scenes/game/game.tscn")
