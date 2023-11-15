extends Control


func _ready():
	# Dodaje elementy do menu rozwijanego MaxConnectionsInput w scenie Host Menu.
	# Elementy to liczby całkowite od 10 do 2 w kolejności malejącej.
	for i in range(10, 1, -1):
		$MaxConnectionsInput.add_item("{i}".format({"i": i}))


func _on_host_button_button_down():
	MultiplayerManager.set_username($UsernameInput.text)
	MultiplayerManager.create_game($PortInput.text.to_int(), $MaxConnectionsInput.text.to_int())
	get_tree().change_scene_to_file("res://scenes/ui/lobby_menu/lobby_menu.tscn")
