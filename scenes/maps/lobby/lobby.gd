extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	# Ukrywa przycisk "Start Game", jeśli użytkownik nie jest hostem
	if !multiplayer.is_server():
		$StartGameButton.hide()
	
	# Aktualizuje listę graczy na starcie
	_update_display_player_list()
	
	# Aktualizuje listę graczy, gdy nowy gracz dołącza lub opuszcza grę
	GameManager.player_registered.connect(_update_display_player_list)
	GameManager.player_deregistered.connect(_update_display_player_list)


func _on_start_game_button_button_down():
	# Umożliwia hostowi rozpoczęcie gry
	if multiplayer.is_server():
		# Informuje klientów o rozpoczęciu gry
		start_game.rpc()


# Rozpoczyna grę
@rpc("call_local", "reliable")
func start_game():
	# Przestaje aktualizować listę graczy
	GameManager.player_registered.disconnect(_update_display_player_list)
	GameManager.player_deregistered.disconnect(_update_display_player_list)

	GameManager.start_game()


# Aktualizuje wyświetlaną listę graczy
func _update_display_player_list(id = null, player = null):
	var player_list_text = "Lista graczy:\n"
	var idx = 1
	for i in GameManager.get_registered_players():
		# Dodaje numeracje graczy
		player_list_text += str(idx) + '. '

		# Dodaje nazwę użytkownika gracza
		player_list_text += GameManager.get_registered_player_key(i, "username")

		# Dodaje symbol nowej linii
		player_list_text += "\n"
		idx += 1

	# Wyświetla zaktualizowaną listę graczy
	$PlayerList.text = player_list_text
