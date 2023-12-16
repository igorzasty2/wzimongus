extends Control


func _ready():
	# Dodaje liczby całkowite od 10 do 2 do menu rozwijanego MaxConnectionsInput
	for i in range(10, 1, -1):
		$MaxConnectionsInput.add_item("{i}".format({"i": i}))


func _on_host_button_button_down():
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")

	# Ustawia wybraną nazwę użytkownika w GameManager, korzystając z tekstu wprowadzonego w UsernameInput.
	GameManager.set_player_key("username", $UsernameInput.text)

	# Inicjuje grę z podanym portem i maksymalną liczbą połączeń, pobranymi z PortInput i MaxConnectionsInput.
	GameManager.create_game($PortInput.text.to_int(), $MaxConnectionsInput.text.to_int())
