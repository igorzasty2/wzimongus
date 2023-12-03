extends Control


func _on_join_button_button_down():
	# Ustawia nazwę użytkownika w GameManager, używając wartości z pola UsernameInput.
	GameManager.set_player_key("username", $UsernameInput.text)

	# Dołącza do gry, używając adresu IP i portu z pól AddressInput i PortInput.
	GameManager.join_game($AddressInput.text, $PortInput.text.to_int())
