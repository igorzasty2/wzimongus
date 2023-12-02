# Odpowiada za logikę lobby

extends Control

func _ready():
	# Ukrywa przycisk, jeśli użytkownik nie jest hostem
	if !multiplayer.is_server():
		$LobbyUI/StartGameButton.hide()
	
	# Początkowe wyświetlenie listy graczy
	_update_display_player_list()
	
	# Sprawienie, aby za każdym razem, gdy gracz dołącza lub
	# opuszcza listę graczy, była ona wyświetlana ponownie
	GameManager.player_registered.connect(_update_display_player_list)
	GameManager.player_deregistered.connect(_update_display_player_list)


func _on_start_game_button_button_down():
	# Tylko host jest w stanie rozpocząć grę
	if multiplayer.is_server():
		# Wysyłamy do klientów informację o rozpoczęciu gry
		start_game.rpc()


# Funkcja odpowiadająca za rozpoczęcie gry
@rpc("call_local", "reliable")
func start_game():
	# Chowamy lobby
	$LobbyUI.hide()
	
	# Wyświetlanie listy graczy nie będzie już aktualizowane.
	GameManager.player_registered.disconnect(_update_display_player_list)
	GameManager.player_deregistered.disconnect(_update_display_player_list)

	GameManager.start_game()

	# Ładujemy mapę na serwerze, zostanie ona zsynchronizowana z klientami przez MapSpawner
	if multiplayer.is_server():
		_change_map.call_deferred(load("res://scenes/map/map.tscn"))


# Funkcja dla serwera odpowiadająca za zmianę mapy
func _change_map(scene: PackedScene):
	var map = $Map

	# Usuwamy obecną mapę
	for i in map.get_children():
		map.remove_child(i)
		i.queue_free()
	
	# Wyświetlamy nową mapę
	map.add_child(scene.instantiate())


# Wyświetla listę graczy na ekranie
func _update_display_player_list(id = null, player = null):
	var player_list_text = "Lista graczy:\n"
	var idx = 1
	for i in GameManager.get_registered_players():
		# Numerowanie graczy
		player_list_text += str(idx) + '. '

		# Wyświetlanie nazwiska gracza
		player_list_text += GameManager.get_registered_player_info(i, "username")

		# Newline symbol
		player_list_text += "\n"
		idx += 1

	# Wyświetlanie całości
	$LobbyUI/PlayerList.text = player_list_text
