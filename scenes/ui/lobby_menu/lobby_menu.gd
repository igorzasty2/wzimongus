extends Control


func _on_start_game_button_button_down():
	MultiplayerManager.load_game.rpc("res://scenes/map/map.tscn")
