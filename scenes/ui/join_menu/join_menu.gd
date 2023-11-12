extends Control


func _on_join_button_button_down():
	MultiplayerManager.set_username($UsernameInput.text)
	MultiplayerManager.join_game($AddressInput.text, $PortInput.text.to_int())
	get_tree().change_scene_to_file("res://scenes/ui/lobby_menu/lobby_menu.tscn")
