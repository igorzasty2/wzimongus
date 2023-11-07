extends Control

@export var Address = "127.0.0.1"
@export var port = 8998
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
	
func connected_to_server():
	print("Connected to server")

func connection_failed():
	print("Connection failed")

func _on_host_button_down():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 10)
	
	if error != OK:
		print("cannot host: " + error)
		return
	
	# Might be useful for game optimization
	# peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for players...")

func _on_join_button_down():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(Address, port)
	
	# Might be useful for game optimization	
	# peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)

@rpc("any_peer", "call_local")
func start_game():
	var scene = load("res://scenes/map/map.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()

func _on_start_game_button_down():
	start_game.rpc()
	
