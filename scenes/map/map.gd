# Definiuje mapę gry.

extends Node2D

@export var PlayerScene : PackedScene

func _ready():
	# Tworzy graczy na serwerze, a następnie MultiplayerSpawner synchronizuje je z klientami.
	if multiplayer.is_server():
		# Sprawia, że gracz jest usuwany z mapy po opuszczeniu gry.
		MultiplayerManager.player_deregistered.connect(_remove_player)
		
		# Tworzy wszystkich graczy jeden po drugim.
		for i in MultiplayerManager.current_game["registered_players"]:
			_add_player(i)
		
		# Losuje taski wszystkim graczom
		TaskManager.assign_tasks_server(2)


# Tworzy gracza w losowej pozycji na mapie.
func _add_player(id):
	var player = preload("res://scenes/player/player.tscn").instantiate()
	# To jest nazwa Node'a.
	player.name = str(id)

	player.id = id
	player.username = MultiplayerManager.current_game["registered_players"][id].username

	player.position = Vector2(randi_range(0, 1152), randi_range(0, 648))

	# Dodaje Node na mape.
	$Players.add_child(player, true)


# Usuwa postać gracza, gdy ten opuszcza grę.
func _remove_player(id):
	if $Players.has_node(str(id)):
		$Players.get_node(str(id)).queue_free()
