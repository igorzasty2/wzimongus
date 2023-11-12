extends Control


func _ready():
	for i in range(10, 1, -1):
		$MaxConnectionsInput.add_item("{i}".format({"i": i}))


func _on_host_button_button_down():
	MultiplayerManager.set_username($UsernameInput.text)
	MultiplayerManager.create_game($PortInput.text.to_int(), $MaxConnectionsInput.text.to_int())
	get_tree().change_scene_to_file("res://scenes/ui/lobby_menu/lobby_menu.tscn")
