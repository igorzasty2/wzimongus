extends Node2D

func _ready():
	# Uruchamia synchronizację czasu.
	NetworkTime.start()

	# Włącza ekran ładowania.
	var loading_screen = preload("res://scenes/ui/loading_screen/loading_screen.tscn").instantiate()
	add_child(loading_screen)
	loading_screen.show()

	# Spawnuje zarejestrowanych graczy.
	for i in GameManager.get_registered_players():
		_spawn_player(i)

	# Despawnuje wyrejestrowanego gracza.
	GameManager.player_deregistered.connect(_remove_player)

func _exit_tree():
	# Zatrzymuje synchronizację czasu.
	NetworkTime.stop()
	
	for i in $Players.get_children():
		i.queue_free()

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
