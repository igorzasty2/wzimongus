extends Node2D

@export var PlayerScene : PackedScene


func _ready():
	if multiplayer.is_server():
		# Sprawia, że gracz jest usuwany z mapy po opuszczeniu gry.
		GameManager.player_deregistered.connect(_remove_player)

		# Tworzy wszystkich graczy jeden po drugim.
		for i in GameManager.get_registered_players():
			_add_player(i)


# Dodaje nowego gracza do mapy.
func _add_player(id: int):
	var player = preload("res://scenes/player/player.tscn").instantiate()

	player.name = str(id)
	player.position = Vector2(randi_range(0, 1152), randi_range(0, 648))

	$Players.add_child(player, true)


# Usuwa gracza z mapy.
func _remove_player(id: int):
	if $Players.has_node(str(id)):
		$Players.get_node(str(id)).queue_free()
