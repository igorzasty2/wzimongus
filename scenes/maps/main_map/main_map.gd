extends Node2D

signal load_finished

@onready var loading_screen = $LoadingScreen
@onready var camera = $Camera

func _ready():
	hide()

	# Spawnuje zarejestrowanych graczy.
	for i in GameManager.get_registered_players():
		_spawn_player(i)

	# Despawnuje wyrejestrowanego gracza.
	GameManager.player_deregistered.connect(_remove_player)

	# Uruchamia synchronizację czasu.
	NetworkTime.start()

	# Czeka na synchronizację czasu.
	if multiplayer.is_server():
		for id in GameManager.get_registered_players():
			if id == 1:
				continue
			while not NetworkTime.is_client_synced(id):
				await NetworkTime.after_client_sync
		
		_start_game.rpc()


func _exit_tree():
	# Zatrzymuje synchronizację czasu.
	NetworkTime.stop()

@rpc("call_local", "reliable")
func _start_game():
	# Włącza ekran ładowania.
	camera.enabled = true
	loading_screen.play()
	load_finished.emit()
	show()


## Spawnuje gracza na mapie.
func _spawn_player(id: int):
	var player = preload("res://scenes/player/player.tscn").instantiate()

	player.name = str(id)

	# Ustawia pozycję gracza.
	if multiplayer.is_server():
		player.position = Vector2(randi_range(0, 100), randi_range(0, 100))

	$Players.add_child(player)

	# Ustawia kamerę na gracza.
	if GameManager.get_current_player_id() == id:
		$Camera.player = player


## Usuwa gracza z mapy.
func _remove_player(id: int):
	if $Players.has_node(str(id)):
		$Players.get_node(str(id)).queue_free()
