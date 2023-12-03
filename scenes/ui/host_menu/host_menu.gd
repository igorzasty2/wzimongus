extends Control


func _ready():
	# Dodaje elementy do menu rozwijanego MaxConnectionsInput w scenie Host Menu.
	# Elementy to liczby całkowite od 10 do 2 w kolejności malejącej.
	for i in range(10, 1, -1):
		$MaxConnectionsInput.add_item("{i}".format({"i": i}))


func _on_host_button_button_down():
	# Ustawia nazwę użytkownika i maksymalną liczbę połączeń w GameManager.
	GameManager.set_player_key("username", $UsernameInput.text)

	# Tworzy grę o określonym porcie i maksymalnej liczbie połączeń w GameManager.
	GameManager.create_game($PortInput.text.to_int(), $MaxConnectionsInput.text.to_int())
