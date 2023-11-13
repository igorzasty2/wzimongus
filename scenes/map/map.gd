# Definiuje mapę gry.
extends Node2D

@export var PlayerScene : PackedScene

func _ready():
	if multiplayer.is_server():
		# multiplayer.peer_connected.connect()
		# multiplayer.peer_disconnected.connect()

		# for i in multiplayer.get_peers():
			# add_player(i)
			# print(i)
		
		# add_player(1)
		
		# for i in MultiplayerManager.players:
			# print(i)

		# for i in MultiplayerManager.players:
			# add_player(i)

		for i in MultiplayerManager.players:
			add_player(i)


func add_player(id: int):
	var player = preload("res://scenes/player/player.tscn").instantiate()
	player.id = id
	# player.player = id
	player.position = Vector2(randi_range(0, 1152), randi_range(0, 648))
	player.name = str(id)
	player.nickname = MultiplayerManager.players[id].username
	$Players.add_child(player, true)


	# Stwórz instancję postaci gracza dla każdego podłączonego gracza.
	# for i in MultiplayerManager.players:
	# 	var currentPlayer = PlayerScene.instantiate()
	# 	currentPlayer.id = i
	# 	currentPlayer.nickname = str(MultiplayerManager.players[i].username)
	# 	add_child(currentPlayer, true)

	# 	# Losowo pozycjonuj postać gracza na mapie.
	# 	currentPlayer.global_position = Vector2(randi_range(0, 1152), randi_range(0, 648))


func _process(delta):
	pass
