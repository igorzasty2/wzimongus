# Definiuje mapę gry.
extends Node2D

@export var PlayerScene : PackedScene

func _ready():
	if multiplayer.is_server():
		# Sprawia, że gracz jest usuwany z mapy po opuszczeniu gry. 
		multiplayer.peer_disconnected.connect(remove_player)

		# Odradza wszystkich graczy jeden po drugim.
		for i in MultiplayerManager.players:
			add_player(i)

# Odradza gracza w losowej pozycji na mapie.
func add_player(id: int):
	var player = preload("res://scenes/player/player.tscn").instantiate()
	# To jest nazwa Node'a.
	player.name = str(id)
	player.id = id
	player.position = Vector2(randi_range(0, 1152), randi_range(0, 648))
	player.nickname = MultiplayerManager.players[id].username
	# Dodaje Node na mape.
	$Players.add_child(player, true)


# Usuwa postać gracza, gdy ten opuszcza grę.
func remove_player(id: int):
	if not $Players.has_node(str(id)):
		return 
	
	# Usuwa odpowiednią postać z mapy.
	$Players.get_node(str(id)).queue_free()
