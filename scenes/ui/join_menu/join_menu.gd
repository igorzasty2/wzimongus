extends Control


func _on_join_button_button_down():
	# Ustawia nazwę użytkownika w GameManager na podstawie tekstu wprowadzonego w polu tekstowym UsernameInput.
	GameManager.set_player_key("username", $UsernameInput.text)

	# Dołącza do gry na podstawie adresu IP i portu wprowadzonych w polach tekstowych AddressInput i PortInput.
	GameManager.join_game($AddressInput.text, $PortInput.text.to_int())
