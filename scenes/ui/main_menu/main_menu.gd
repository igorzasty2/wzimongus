extends Control

func _on_host_button_down():
	MultiplayerManager.set_username($UsernameField.text)
	MultiplayerManager.create_game()

func _on_join_button_down():
	MultiplayerManager.set_username($UsernameField.text)
	MultiplayerManager.join_game()

func _on_start_game_button_down():
	MultiplayerManager.load_game.rpc("res://scenes/map/map.tscn")
