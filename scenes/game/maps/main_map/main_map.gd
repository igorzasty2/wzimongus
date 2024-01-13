extends Node2D

signal load_finished()

@onready var _players = $Players
@onready var _camera = $Camera
@onready var _loading_screen = $LoadingScreen
@onready var _start_positions = $StartPositions.get_children()
@onready var _minigame_window = $MinigameWindow
@onready var _voting_canvas = $VotingCanvas

func _ready():
	# Uruchamia synchronizację czasu.
	NetworkTime.start()

	hide()
	GameManager.set_input_disabled_status(true)

	# Spawnuje zarejestrowanych graczy.
	for i in GameManager.get_registered_players():
		_spawn_player(i)

	# Despawnuje wyrejestrowanego gracza.
	GameManager.player_deregistered.connect(_remove_player)

	# Czeka na synchronizację czasu.
	if multiplayer.is_server():
		for i in GameManager.get_registered_players():
			if i == 1:
				continue
			while not NetworkTime.is_client_synced(i):
				await NetworkTime.after_client_sync

		_start_game.rpc()


func _exit_tree():
	# Zatrzymuje synchronizację czasu.
	NetworkTime.stop()


@rpc("call_local", "reliable")
## Włącza ekran ładowania.
func _start_game():
	show()
	_camera.enabled = true
	_loading_screen.play()
	load_finished.emit()


func _on_loading_screen_finished():
	_loading_screen.hide()


## Spawnuje gracza na mapie.
func _spawn_player(id: int):
	var player = preload("res://scenes/characters/player/player.tscn").instantiate()
	
	player.name = str(id)

	# Ustawia startową pozycję gracza.
	if multiplayer.is_server():
		player.position = _start_positions[GameManager.get_registered_players().keys().find(id)].position

	_players.add_child(player)
	
	player.activate_player_shaders()

	if GameManager.get_current_player_id() == id:
		# Ustawia kamerę.
		_camera.target = player
		_camera.global_position = player.global_position
	
		# Włącza światło
		player.activate_lights()

		player.vent_entered.connect(_update_player_input)
		player.vent_exited.connect(_update_player_input)


## Usuwa gracza z mapy.
func _remove_player(id: int, _player: Dictionary = {}):
	if _players.has_node(str(id)):
		_players.get_node(str(id)).queue_free()


## Aktualizuje status wejścia gracza.
func _update_player_input():
	var current_player_node = _players.get_node(str(GameManager.get_current_player_id())) if _players != null else null

	var is_player_in_vent = current_player_node.is_in_vent if current_player_node != null else false
	var is_minigame_window_visible = _minigame_window.visible if _minigame_window != null else false
	var is_voting_in_progress = _voting_canvas.get_child_count() > 0 if _voting_canvas != null else false
	var is_loading_screen_visible = _loading_screen.visible if _loading_screen != null else false

	var is_input_disabled = is_player_in_vent || is_minigame_window_visible || is_voting_in_progress || is_loading_screen_visible

	GameManager.set_input_disabled_status(is_input_disabled)


func close_modals():
	# Zamyka wszystkie okna.
	_minigame_window.close_minigame()

	# Zamyka głosowanie.
	for i in _voting_canvas.get_children(): i.queue_free()
