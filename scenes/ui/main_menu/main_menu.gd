extends Control

@export var Address = "127.0.0.1"
@export var Port = 8998

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func peer_connected(id):
	print("player connected " + str(id))

func peer_disconnected(id):
	print("player disconnected " + str(id))
	
## Sends player information to the host peer.
func connected_to_server():
	print("Connected to server")
	send_player_information.rpc_id(1, $UsernameField.text, multiplayer.get_unique_id())

## Called on failing connecting to the server.
func connection_failed():
	print("Connection failed")

## Manages recording new player's information if necessary
## to localy stored GameManager on every peer. If peer
## happens to be a host peer then it also sends full list
## of players to every peer.
@rpc("any_peer")
func send_player_information(name, id):
	if !GameManager.Players.has(id):
		GameManager.Players[id] = {
			"id": id,
			"name": name,
		}
	
	if multiplayer.is_server():
		for i in GameManager.Players:
			send_player_information.rpc(GameManager.Players[i].name, i)

## Creates a new host peer and creates a server for it
## on a given Port. If a peer couldn't host the server
## the game wouldn't start.
func _on_host_button_down():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(Port, 10)
	
	if error != OK:
		print("cannot host: " + error)
		return
	
	# Might be useful for game optimization
	# peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for players...")
	send_player_information($UsernameField.text, multiplayer.get_unique_id())

## Creates a new peer and connects this peer to a given server
## located on the Address:Port.
## 
## Address:Port is 127.0.0.1:8000 for now.
func _on_join_button_down():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(Address, Port)
	
	# Might be useful for game optimization	
	# peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)

## Starts game for every player who is connected to a given server
@rpc("any_peer", "call_local")
func start_game():
	var scene = load("res://scenes/map/map.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()

## StartGame button function which can be pressed by anyone
## who's connected to the server. Button starts the game 
func _on_start_game_button_down():
	start_game.rpc()
	
