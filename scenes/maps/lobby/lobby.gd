extends Node2D

signal load_finished

@onready var players = $Players
@onready var spawn_points = $SpawnPoints
@onready var camera = $Camera
@onready var start_game_button = $StartGameButton
@onready var chat = $Chat
@onready var server_advertiser = $ServerAdvertiser

func _ready():
	# Uruchamia synchronizację czasu.
	NetworkTime.start()

	hide()
	GameManager.set_input_status(false)

	# Spawnuje zarejestrowanych graczy.
	for i in GameManager.get_registered_players():
		_spawn_player(i)

	# Ukrywa przycisk rozpoczęcia gry przed klientami.
	if !multiplayer.is_server():
		start_game_button.hide()

	# Spawnuje nowych graczy.
	GameManager.player_registered.connect(_on_player_registered)

	# Despawnuje wyrejestrowanego gracza.
	GameManager.player_deregistered.connect(_on_player_deregistered)

	# Włącza broadcast serwera.
	if multiplayer.is_server():
		_update_broadcast_info()

		GameManager.player_registered.connect(_update_broadcast_info)
		GameManager.player_deregistered.connect(_update_broadcast_info)

	# Czeka na synchronizację czasu.
	if !multiplayer.is_server():
		await NetworkTime.after_sync

	show()
	camera.enabled = true
	GameManager.set_input_status(true)
	load_finished.emit()


func _exit_tree():
	# Zatrzymuje synchronizację czasu.
	NetworkTime.stop()

	GameManager.player_registered.disconnect(_on_player_registered)
	GameManager.player_deregistered.disconnect(_on_player_deregistered)

	if multiplayer.is_server():
		GameManager.player_registered.disconnect(_update_broadcast_info)
		GameManager.player_deregistered.disconnect(_update_broadcast_info)


func _update_broadcast_info(_id: int = 0, _player: Dictionary = {}):
	server_advertiser.serverInfo = GameManager.get_server_settings()
	server_advertiser.serverInfo["player_count"] = GameManager.get_registered_players().size()


func _on_start_game_button_button_down():
	GameManager.start_game()


func _on_player_registered(id: int, player: Dictionary):
	_spawn_player(id)
	camera.shake(1.5, 10)

	if multiplayer.is_server():
		chat.send_system_message("Gracz " + player.username + " dołączył do gry.")


func _on_player_deregistered(id: int, player: Dictionary):
	_remove_player(id)

	if multiplayer.is_server():
		chat.send_system_message("Gracz " + player.username + " opuścił grę.")


## Spawnuje gracza na mapie.
func _spawn_player(id: int):
	var player = preload("res://scenes/player/player.tscn").instantiate()

	player.name = str(id)

	# Ustawia startową pozycję gracza.
	player.position = spawn_points.get_child(GameManager.get_registered_players().keys().find(id)).position

	# Ustawia pozycję i animację gracza na podstawie aktualnych danych.
	if GameManager.lobby_data_at_registration.has(id):
		player.position = GameManager.lobby_data_at_registration[id]["position"]
		player.last_direction_x = GameManager.lobby_data_at_registration[id]["last_direction_x"]
		GameManager.lobby_data_at_registration.erase(id)

	players.add_child(player)

	# Ustawia kamerę.
	if GameManager.get_current_player_id() == id:
		camera.target = player
		camera.global_position = player.global_position


## Usuwa gracza z mapy.
func _remove_player(id: int):
	if players.has_node(str(id)):
		players.get_node(str(id)).queue_free()
