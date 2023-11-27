extends Control


func _on_join_button_button_down():
	# Ustawia nazwę użytkownika w MultiplayerManager na podstawie tekstu wprowadzonego w polu tekstowym UsernameInput.
	MultiplayerManager.set_username($UsernameInput.text)

	# Dołącza do gry na podstawie adresu IP i portu wprowadzonych w polach tekstowych AddressInput i PortInput.
	MultiplayerManager.join_game($AddressInput.text, $PortInput.text.to_int())
