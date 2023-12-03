extends Node2D

@export var PlayerScene : PackedScene


func _ready():
	if multiplayer.is_server():
		# Usuwa gracza z mapy po jego wyrejestrowaniu.
		GameManager.player_deregistered.connect(_remove_player)

		# Inicjuje graczy zarejestrowanych w GameManager.
		for i in GameManager.get_registered_players():
			_add_player(i)

	# Ustawia etykietę typu na "Impostor" lub "Crewmate".
	$TypeLabel.text = "Impostor" if GameManager.get_current_player_key("impostor") else "Crewmate"


# Dodaje nowego gracza na mapę.
func _add_player(id: int):
	# Ładuje i tworzy instancję gracza.
	var player = preload("res://scenes/player/player.tscn").instantiate()

	# Nadaje graczowi id i losową pozycję.
	player.name = str(id)
	player.position = Vector2(randi_range(0, 1152), randi_range(0, 648))

	# Dodaje gracza do drzewa sceny.
	$Players.add_child(player, true)


# Usuwa gracza z mapy.
func _remove_player(id: int):
	# Sprawdza, czy gracz istnieje w drzewie sceny i usuwa go.
	if $Players.has_node(str(id)):
		$Players.get_node(str(id)).queue_free()
