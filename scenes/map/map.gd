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
		TaskManager.assign_tasks_server(1)
	var interaction_points = get_tree().get_nodes_in_group("interaction_points")
	for i in interaction_points:
		i.character_entered.connect(_on_interaction_point_character_entered)
		i.character_exited.connect(_on_interaction_point_character_exited)


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


func _on_interaction_point_character_entered(character, minigame):
	if $Players.has_node(str(character.id)):
		$Players.get_node(str(character.id)).show_use_button(character.id, minigame)


func _on_interaction_point_character_exited(character):
	if $Players.has_node(str(character.id)):
		$Players.get_node(str(character.id)).hide_use_button(character.id)
