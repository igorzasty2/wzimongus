extends Node2D

signal load_finished

@onready var loading_screen = $LoadingScreen
@onready var camera = $Camera
@onready var players = $Players

func _ready():
	hide()
	camera.enabled = false
	GameManager.set_input_status(false)

	# Spawnuje zarejestrowanych graczy.
	for i in GameManager.get_registered_players():
		_spawn_player(i)

	# Despawnuje wyrejestrowanego gracza.
	GameManager.player_deregistered.connect(_remove_player)

	# Uruchamia synchronizację czasu.
	NetworkTime.start()

	# Czeka na synchronizację czasu.
	if multiplayer.is_server():
		for i in GameManager.get_registered_players():
			if i == 1:
				continue
			while not NetworkTime.is_client_synced(i):
				await NetworkTime.after_client_sync

		_start_game.rpc()


func _exit_tree():
	GameManager.player_deregistered.disconnect(_remove_player)
	
	# Zatrzymuje synchronizację czasu.
	NetworkTime.stop()


@rpc("call_local", "reliable")
## Włącza ekran ładowania.
func _start_game():
	show()
	camera.enabled = true
	loading_screen.connect("finished", _on_loading_screen_finished)
	loading_screen.play()
	load_finished.emit()


func _on_loading_screen_finished():
	loading_screen.disconnect("finished", _on_loading_screen_finished)
	loading_screen.hide()
	loading_screen.queue_free()
	GameManager.set_input_status(true)


## Spawnuje gracza na mapie.
func _spawn_player(id: int):
	var player = preload("res://scenes/player/player.tscn").instantiate()

	player.name = str(id)

	# Ustawia startową pozycję gracza.
	if multiplayer.is_server():
		player.position = Vector2(randi_range(0, 100), randi_range(0, 100))

	players.add_child(player)

	# Ustawia kamerę.
	if GameManager.get_current_player_id() == id:
		camera.player = player


## Usuwa gracza z mapy.
func _remove_player(id: int):
	if players.has_node(str(id)):
		players.get_node(str(id)).queue_free()
