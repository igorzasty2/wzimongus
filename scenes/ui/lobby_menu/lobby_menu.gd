extends Control

func _ready() -> void:
	# Ukrywa przycisk, jeśli użytkownik nie jest hostem
	if !multiplayer.is_server():
		$LobbyUI/StartGameButton.hide()
	
	update_display_player_list(multiplayer.get_unique_id(), MultiplayerManager.player_info)
	MultiplayerManager.player_connected.connect(update_display_player_list)

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

	# Ładujemy mapę na serwerze, zostanie ona zsynchronizowana z klientami przez MapSpawner
	if multiplayer.is_server():
		change_map.call_deferred(load("res://scenes/map/map.tscn"))


# Funkcja dla serwera odpowiadająca za zmianę mapy
func change_map(scene: PackedScene):
	var map = $Map

	# Usuwamy obecną mapę
	for i in map.get_children():
		map.remove_child(i)
		i.queue_free()
	
	# Wyświetlamy nową mapę
	map.add_child(scene.instantiate())

# 
func update_display_player_list(id, player_info):
	var players = MultiplayerManager.players
	var players_display = "lista graczy:\n"
	for i in players:
		
		players_display += (players[i].username)
		players_display += "\n"
	
	$LobbyUI/PlayerList.text = players_display
		
