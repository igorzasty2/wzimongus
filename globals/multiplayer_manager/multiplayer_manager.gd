# Ten skrypt definiuje węzeł MultiplayerManager, który obsługuje połączenia wieloosobowe i informacje o graczach.
extends Node

# Sygnał, który jest emitowany, gdy gracz dołącza do gry.
signal player_connected(peer_id, player_info)
# Sygnał, który jest emitowany, gdy gracz się rozłącza.
signal player_disconnected(peer_id)

# Słownik przechowujący informacje o połączonych graczach.
var players = {}

# Słownik przechowujący informacje o bieżącym graczu.
var player_info = {
	"username": ""
}


func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


# Funkcja pozwalająca na stworzenie nowego serwera.
func create_game(port, max_connections):
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, max_connections)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

	# Dodaje obecnego gracza do listy połączonych graczy.
	# W tym momencie nie ma żadnych połączonych graczy, więc nie potrzeba wysyłać go do połączonych klientów.
	_add_new_player(1, player_info)


# Funkcja pozwalaja na dołączenie do istniejącej gry.
func join_game(address, port):
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, port)
	if error:
		return error
	multiplayer.multiplayer_peer = peer


# Funkcja pozwalająca na zmianę nazwy gracza.
func set_username(username):
	player_info["username"] = username


# Funkcja wywoływana na serwerze po dołączeniu nowego gracza.
func _on_player_connected(id):
	pass


# Funkcja wywoływana na serwerze po rozłączeniu gracza.
func _on_player_disconnected(id):
	players.erase(id)
	# Powiadamia wszystkich graczy o rozłączeniu gracza.
	_delete_player.rpc(id)
	player_disconnected.emit(id)	


# Funkcja wywoływana u klienta po połączeniu z serwerem.
# Wysyła informacje o graczu do serwera.
func _on_connected_ok():
	_register_player.rpc_id(1, player_info)


# Funkcja wywoływana u klienta po nieudanym połączeniu z serwerem.
func _on_connected_fail():
	multiplayer.multiplayer_peer = null


# Funkcja wywoływana u klienta po rozłączeniu z serwerem.
func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()


# Funkcja wywoływanana na serwerze po otrzymaniu informacji o graczu.
@rpc("any_peer", "reliable")
func _register_player(player_info):
	# Dodaje nowego gracza do listy połączonych graczy.
	var id = multiplayer.get_remote_sender_id()
	_add_new_player(id, player_info)

	# Wysyłanie do nowego gracza informacji o wszystkich połączonych graczach.
	for i in players:
		_add_new_player.rpc_id(id, i, players[i])

	# Wysyłanie do wszystkich połączonych graczy informacji o nowym graczu.
	_add_new_player.rpc(id, player_info)


# Funkcja pozwalająca na dodanie nowego gracza do listy połączonych graczy.
@rpc("reliable")
func _add_new_player(id, player):
	players[id] = player
	player_connected.emit(id, player)


# Funkcja pozwalająca na usunięcie gracza z listy połączonych graczy.
@rpc("reliable")
func _delete_player(id):
	players.erase(id)
	player_disconnected.emit(id)
