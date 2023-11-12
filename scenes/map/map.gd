extends Node2D

@export var PlayerScene : PackedScene

## Called when the node enters the scene tree for the first time.
##
## On scene load looks up GameManager players dictionary then spawns them 
## on every available spawn point.
##
## IMPORTANT: _ready() will throw an error if the amount of players is
## greater than amount of spawn points.
func _ready():
	var spawnPoints = $SpawnPoints.get_children()
	var index = 0
	for i in GameManager.players:
		var currentPlayer = PlayerScene.instantiate()
		currentPlayer.authority_id = str(GameManager.players[i].id)
		currentPlayer.nickname = str(GameManager.players[i].name)
		add_child(currentPlayer)
		print(spawnPoints[index])
		currentPlayer.global_position = spawnPoints[index].global_position
		
		index += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
