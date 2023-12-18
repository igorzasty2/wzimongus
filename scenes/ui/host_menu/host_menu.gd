extends Control


func _on_host_button_button_down():
	var username = $InputsContainer/UsernameContainer/UsernameInput.text
	var port = $InputsContainer/PortContainer/PortInput.text.to_int()
	var max_connections = $InputsContainer/MaxConnectionsContainer/MaxConnectionsInputContainer/MaxConnectionsInput.text.to_int()
	var max_lectureres = $InputsContainer/MaxLecturersContainer/MaxLecturersInputContainer/MaxLecturersInput.text.to_int()

	GameManager.set_player_key("username", username)
	GameManager.host_game(port, max_connections, max_lectureres)

	get_tree().change_scene_to_file("res://scenes/game/game.tscn")
