extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

## Creates a new host peer and creates a server for it
## on a given Port. If a peer couldn't host the server
## the game wouldn't start.
func _on_host_button_down():
	GameManager.set_username($UsernameField.text)
	GameManager.create_game()

## Creates a new peer and connects this peer to a given server
## located on the Address:Port.
## 
## Address:Port is 127.0.0.1:8000 for now.
func _on_join_button_down():
	GameManager.set_username($UsernameField.text)
	GameManager.join_game()

## StartGame button function which can be pressed by anyone
## who's connected to the server. Button starts the game 
func _on_start_game_button_down():
	GameManager.load_game.rpc("res://scenes/map/map.tscn")
