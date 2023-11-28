# Definiuje mapę gry.

extends Node2D

@export var PlayerScene : PackedScene

func _ready():
	# Tworzy graczy na serwerze, a następnie MultiplayerSpawner synchronizuje je z klientami.
	if multiplayer.is_server():
		# Sprawia, że gracz jest usuwany z mapy po opuszczeniu gry.
		multiplayer.peer_disconnected.connect(_remove_player)

		# Tworzy wszystkich graczy jeden po drugim.
		for i in MultiplayerManager.players:
			_add_player(i)


# Tworzy gracza w losowej pozycji na mapie.
func _add_player(id: int):
	var player = preload("res://scenes/player/player.tscn").instantiate()
	# To jest nazwa Node'a.
	player.name = str(id)

	player.id = id
	player.username = MultiplayerManager.players[id].username

	player.position = Vector2(randi_range(0, 1152), randi_range(0, 648))
	
	# Dodaje Node na mape.
	$Players.add_child(player, true)


# Usuwa postać gracza, gdy ten opuszcza grę.
func _remove_player(id: int):
	if $Players.has_node(str(id)):
		$Players.get_node(str(id)).queue_free()
