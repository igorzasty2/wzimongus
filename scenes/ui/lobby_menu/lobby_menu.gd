# Zarządza logiką lobby
extends Control

func _ready():
	# Ukrywa przycisk "Start Game", jeśli użytkownik nie jest hostem
	if !multiplayer.is_server():
		$LobbyUI/StartGameButton.hide()
	
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
	# Ukrywa interfejs lobby
	$LobbyUI.hide()
	
	# włączenie loading_screena
	var loading_screen = preload("res://scenes/ui/loading_screen/loading_screen.tscn").instantiate()
	add_child(loading_screen)
	loading_screen.show()
	
	# Przestaje aktualizować listę graczy
	GameManager.player_registered.disconnect(_update_display_player_list)
	GameManager.player_deregistered.disconnect(_update_display_player_list)

	GameManager.start_game()

	# Ładuje mapę na serwerze, synchronizując ją z klientami
	if multiplayer.is_server():
		_change_map.call_deferred(load("res://scenes/map/map.tscn"))


# Zmienia mapę na serwerze
func _change_map(scene: PackedScene):
	var map = $Map

	# Usuwa obecną mapę
	for i in map.get_children():
		map.remove_child(i)
		i.queue_free()
	
	# Dodaje nową mapę
	map.add_child(scene.instantiate())


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
	$LobbyUI/PlayerList.text = player_list_text


func _on_loading_screen_loading_done():
	$loading_screen.hide()
