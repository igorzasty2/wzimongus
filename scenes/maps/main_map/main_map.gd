extends Node2D

signal load_finished

@onready var players = $Players
@onready var camera = $Camera
@onready var loading_screen = $LoadingScreen
## Pozycje do spawnu gracza
@onready var start_positions = $StartPositions.get_children()


func _ready():
	# Uruchamia synchronizację czasu.
	NetworkTime.start()

	hide()
	GameManager.set_input_status(false)

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
	camera.enabled = true
	loading_screen.play()
	load_finished.emit()


func _on_loading_screen_finished():
	loading_screen.hide()
	# loading_screen.queue_free()


## Spawnuje gracza na mapie.
func _spawn_player(id: int):
	var player = preload("res://scenes/player/player.tscn").instantiate()
	
	player.name = str(id)

	# Ustawia startową pozycję gracza.
	if multiplayer.is_server():
		player.position = start_positions[GameManager.get_registered_players().keys().find(id)].position

	players.add_child(player)
	
	player.activate_player_shaders()

	if GameManager.get_current_player_id() == id:
		# Ustawia kamerę.
		camera.target = player
		camera.global_position = player.global_position
	
		# Włącza światło
		player.activate_lights()

		player.vent_entered.connect(update_player_input)
		player.vent_exited.connect(update_player_input)


## Usuwa gracza z mapy.
func _remove_player(id: int, _player: Dictionary = {}):
	if players.has_node(str(id)):
		players.get_node(str(id)).queue_free()


## Aktualizuje status wejścia gracza.
func update_player_input():
	GameManager.set_input_status(!$Players.get_node(str(GameManager.get_current_player_id())).is_in_vent && !$MinigameMenu.visible && !$VotingCanvas.get_child_count() > 0 && !$LoadingScreen.visible)

func close_modals():
	# Zamyka wszystkie okna.
	$MinigameMenu.close_minigame()

	# Zamyka głosowanie.
	for i in $VotingCanvas.get_children(): i.queue_free()
