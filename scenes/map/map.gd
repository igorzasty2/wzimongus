# Definiuje mapę gry.
extends Node2D

@export var PlayerScene : PackedScene

func _ready():
	# Stwórz instancję postaci gracza dla każdego podłączonego gracza.
	for i in MultiplayerManager.players:
		var currentPlayer = PlayerScene.instantiate()
		currentPlayer.id = i
		currentPlayer.nickname = str(MultiplayerManager.players[i].username)
		add_child(currentPlayer, true)

		# Losowo pozycjonuj postać gracza na mapie.
		currentPlayer.global_position = Vector2(randi_range(0, 1152), randi_range(0, 648))


func _process(delta):
	pass
