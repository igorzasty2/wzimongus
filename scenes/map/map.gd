extends Node2D

@export var PlayerScene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	var spawnPoints = $SpawnPoints.get_children()
	var index = 0
	for i in GameManager.Players:
		var currentPlayer = PlayerScene.instantiate()
		currentPlayer.authority_id = str(GameManager.Players[i].id)
		currentPlayer.nickname = str(GameManager.Players[i].name)
		add_child(currentPlayer)
		print(spawnPoints[index])
		currentPlayer.global_position = spawnPoints[index].global_position
		
		index += 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
