extends Node2D

signal load_finished

@onready var camera = $Camera
@onready var players = $Players
@onready var start_game_button = $StartGameButton
@onready var server_advertiser = $ServerAdvertiser

func _ready():
	# Uruchamia synchronizację czasu.
	NetworkTime.start()

	hide()
	camera.enabled = false
	GameManager.set_input_status(false)

	# Spawnuje zarejestrowanych graczy.
	for i in GameManager.get_registered_players():
		_spawn_player(i)

	# Ukrywa przycisk rozpoczęcia gry przed klientami.
	if !multiplayer.is_server():
		start_game_button.hide()

	GameManager.player_registered.connect(_spawn_player)
	# Despawnuje wyrejestrowanego gracza.
	GameManager.player_deregistered.connect(_remove_player)

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

	if multiplayer.is_server():
		GameManager.player_registered.disconnect(_update_broadcast_info)
		GameManager.player_deregistered.disconnect(_update_broadcast_info)

	GameManager.player_registered.disconnect(_spawn_player)
	GameManager.player_deregistered.disconnect(_remove_player)


func _update_broadcast_info(_id = null, _player = null):
	server_advertiser.serverInfo = GameManager.get_server_settings()
	server_advertiser.serverInfo["player_count"] = GameManager.get_registered_players().size()


func _on_start_game_button_button_down():
	GameManager.start_game()

## Spawnuje gracza na mapie.
func _spawn_player(id: int, _player = null):
	var player = preload("res://scenes/player/player.tscn").instantiate()

	player.name = str(id)

	# Ustawia startową pozycję gracza.
	if multiplayer.is_server():
		player.position = Vector2(randi_range(0, 100), randi_range(0, 100))

	# Ustawia pozycję i animację gracza na podstawie aktualnych danych.
	if GameManager.lobby_data_at_registration.has(id):
		player.position = GameManager.lobby_data_at_registration[id]["position"]
		player.last_direction_x = GameManager.lobby_data_at_registration[id]["last_direction_x"]
		GameManager.lobby_data_at_registration.erase(id)

	players.add_child(player)

	# Ustawia kamerę.
	if GameManager.get_current_player_id() == id:
		camera.player = player


## Usuwa gracza z mapy.
func _remove_player(id: int):
	if players.has_node(str(id)):
		players.get_node(str(id)).queue_free()
