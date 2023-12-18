extends Node2D

@export var PlayerScene : PackedScene


func _ready():
	# Usuwa gracza z mapy po jego wyrejestrowaniu.
	GameManager.player_deregistered.connect(_remove_player)

	# Inicjuje graczy zarejestrowanych w GameManager.
	for i in GameManager.get_registered_players():
		_add_player(i)

	# włączenie loading_screena
	var loading_screen = preload("res://scenes/ui/loading_screen/loading_screen.tscn").instantiate()
	add_child(loading_screen)
	loading_screen.show()
	
# Dodaje nowego gracza na mapę.
func _add_player(id: int):
	# Ładuje i tworzy instancję gracza.
	var player = preload("res://scenes/player/player.tscn").instantiate() as Node

	# Nadaje graczowi id i losową pozycję.
	player.name = str(id)

	if multiplayer.is_server():
		player.position = Vector2(randi_range(0, 100), randi_range(0, 100))

	# Dodaje gracza do drzewa sceny.
	$Players.add_child(player)

	# Ustawia gracza jako własność serwera.
	player.set_multiplayer_authority(1)

	var input = player.find_child("Input")
	if input != null:
		input.set_multiplayer_authority(id)
	
	if id == GameManager.get_current_player_id():
		$Camera.player = player


# Usuwa gracza z mapy.
func _remove_player(id: int):
	# Sprawdza, czy gracz istnieje w drzewie sceny i usuwa go.
	if $Players.has_node(str(id)):
		$Players.get_node(str(id)).queue_free()
