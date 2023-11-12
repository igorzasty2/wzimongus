extends Node
## GameManager is more of a local database which stores
## information about current server and its peers. GameManager
## can be extended further to store the amount of tasks every player
## has done, chat information can be stored here too in further development
## of the game. 

@export var Address = "127.0.0.1"
@export var Port = 8998

var username = ""

## Stores all players info who are connected to the server at the moment. 
var players = {}

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
	send_player_information.rpc_id(1, username, multiplayer.get_unique_id())

## Called on failing connecting to the server.
func connection_failed():
	print("Connection failed")

## Manages recording new player's information if necessary
## to localy stored GameManager on every peer. If peer
## happens to be a host peer then it also sends full list
## of players to every peer.
@rpc("any_peer")
func send_player_information(name, id):
	if !players.has(id):
		players[id] = {
			"id": id,
			"name": name,
		}
	
	if multiplayer.is_server():
		for i in players:
			send_player_information.rpc(players[i].name, i)

func join_game(username = ""):
	self.username = username

	var peer = ENetMultiplayerPeer.new()
	peer.create_client(Address, Port)
	
	# Might be useful for game optimization	
	# peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)


func create_game(username = ""):
	self.username = username

	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(Port, 10)
	
	if error != OK:
		print("cannot host: " + error)
		return
	
	# Might be useful for game optimization
	# peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for players...")
	send_player_information(username, multiplayer.get_unique_id())

## Starts game for every player who is connected to a given server
@rpc("any_peer", "call_local")
func start_game():
	get_tree().change_scene_to_file("res://scenes/map/map.tscn")
