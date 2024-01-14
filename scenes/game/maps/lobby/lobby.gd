## Klasa mapy lobby.
class_name Lobby
extends Node2D

## Emitowany, gdy lobby jest gotowe do gry.
signal load_finished

@onready var _spawn_points = $SpawnPoints
@onready var _players = $Players
@onready var _camera = $Camera
@onready var _server_advertiser = $ServerAdvertiser
@onready var _chat = $Chat
@onready var _lobby_ui = $LobbyUI
@onready var _chat_input = $Chat/ChatContainer/InputText
@onready var _skin_selector = $SkinSelector
@onready var _lobby_settings = $LobbySettings


func _update_player_input():
	var is_chat_visible = _chat_input.visible if _chat_input != null else false
	var is_skin_selector_visible = _skin_selector.visible if _skin_selector != null  else false
	var is_lobby_settings_visible = _lobby_settings.visible if _lobby_settings != null  else false

	var is_input_disabled = is_chat_visible || is_skin_selector_visible || is_lobby_settings_visible
	GameManagerSingleton.set_input_disabled_status(is_input_disabled)


func _ready():
	# Uruchamia synchronizację czasu.
	NetworkTime.start()

	hide()
	GameManagerSingleton.set_input_disabled_status(true)

	# Spawnuje zarejestrowanych graczy.
	for i in GameManagerSingleton.get_registered_players():
		_spawn_player(i)

	# Spawnuje nowych graczy.
	GameManagerSingleton.player_registered.connect(_on_player_registered)

	# Despawnuje wyrejestrowanego gracza.
	GameManagerSingleton.player_deregistered.connect(_on_player_deregistered)

	# Włącza broadcast serwera.
	if multiplayer.is_server():
		_update_broadcast_info()

		GameManagerSingleton.player_registered.connect(_update_broadcast_info)
		GameManagerSingleton.player_deregistered.connect(_update_broadcast_info)
		GameManagerSingleton.server_settings_changed.connect(_update_broadcast_info)

	# Czeka na synchronizację czasu.
	if !multiplayer.is_server():
		await NetworkTime.after_sync

	show()
	_chat.show()
	_lobby_ui.show()
	_camera.enabled = true
	load_finished.emit()
	_update_player_input()


func _exit_tree():
	# Zatrzymuje synchronizację czasu.
	NetworkTime.stop()


func _update_broadcast_info(_id: int = 0, _player: Dictionary = {}):
	_server_advertiser.serverInfo = GameManagerSingleton.get_server_settings().duplicate()
	_server_advertiser.serverInfo["player_count"] = GameManagerSingleton.get_registered_players().size()


func _on_player_registered(id: int, player: Dictionary):
	_spawn_player(id)
	_camera.shake(1.5, 10)

	if multiplayer.is_server():
		_chat.send_system_message("Gracz " + player.username + " dołączył do gry.")


func _on_player_deregistered(id: int, player: Dictionary):
	_remove_player(id)

	if multiplayer.is_server():
		_chat.send_system_message("Gracz " + player.username + " opuścił grę.")


## Spawnuje gracza na mapie.
func _spawn_player(id: int):
	var player = preload("res://scenes/characters/player/player.tscn").instantiate()

	player.name = str(id)

	# Ustawia startową pozycję gracza.
	player.position = _spawn_points.get_child(GameManagerSingleton.get_registered_players().keys().find(id)).position

	# Ustawia pozycję i animację gracza na podstawie aktualnych danych.
	if GameManagerSingleton.lobby_data_at_registration.has(id):
		player.position = GameManagerSingleton.lobby_data_at_registration[id]["position"]
		player.direction_last_x = GameManagerSingleton.lobby_data_at_registration[id]["direction_last_x"]
		GameManagerSingleton.lobby_data_at_registration.erase(id)

	_players.add_child(player)

	# Ustawia kamerę.
	if GameManagerSingleton.get_current_player_id() == id:
		_camera.target = player


## Usuwa gracza z mapy.
func _remove_player(id: int):
	if _players.has_node(str(id)):
		_players.get_node(str(id)).queue_free()
