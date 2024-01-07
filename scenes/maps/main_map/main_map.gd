extends Node2D

signal load_finished

@onready var players = $Players
@onready var camera = $Camera
@onready var loading_screen = $LoadingScreen
## Pozycje do spawnu gracza
@onready var meeting_positions = $MeetingPositions.get_children()

## Indeks aktualnej pozycji spawnu dla gracza
var positions_idx: int = 0

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
	loading_screen.queue_free()
	GameManager.set_input_status(true)


## Spawnuje gracza na mapie.
func _spawn_player(id: int):
	var player = preload("res://scenes/player/player.tscn").instantiate()

	player.name = str(id)

	# Ustawia startową pozycję gracza.
	if multiplayer.is_server():
		player.position = meeting_positions[positions_idx].position
		positions_idx +=1

	players.add_child(player)

	# Ustawia kamerę.
	if GameManager.get_current_player_id() == id:
		camera.target = player
		camera.global_position = player.global_position


## Usuwa gracza z mapy.
func _remove_player(id: int, _player: Dictionary = {}):
	if players.has_node(str(id)):
		players.get_node(str(id)).queue_free()
