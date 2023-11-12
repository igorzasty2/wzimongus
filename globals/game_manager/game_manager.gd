extends Node
## GameManager is more of a local database which stores
## information about current server and its peers. GameManager
## can be extended further to store the amount of tasks every player
## has done, chat information can be stored here too in further development
## of the game. 

const PORT = 8998
const DEFAULT_SERVER_IP = "127.0.0.1"
const MAX_CONNECTIONS = 20

## Stores all players info who are connected to the server at the moment. 
var players = {}

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var player_info = {"username": ""}


# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


## Joins the game as a client.
func join_game(address = ""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer


## Hosts the game as a server.
func create_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	
	send_player_information(player_info["username"], multiplayer.get_unique_id())


func set_username(username):
	player_info["username"] = username


## Called when a new player connects to the server.
func _on_player_connected(id):
	print("player connected " + str(id))


## Called when a player disconnects from the server.
func _on_player_disconnected(id):
	print("player disconnected " + str(id))


## Sends player information to the host peer.
func _on_connected_ok():
	print("Connected to server")
	send_player_information.rpc_id(1, player_info["username"], multiplayer.get_unique_id())


## Called on failing connecting to the server.
func _on_connected_fail():
	print("Connection failed")


## Called when the server disconnects.
func _on_server_disconnected():
	print("Server disconnected")


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


## Starts game for every player who is connected to a given server
@rpc("any_peer", "call_local")
func start_game():
	get_tree().change_scene_to_file("res://scenes/map/map.tscn")
