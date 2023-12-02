# Ten skrypt definiuje węzeł MultiplayerManager, który obsługuje połączenia wieloosobowe i informacje o graczach.

extends Node

# Sygnał emitowany, gdy gracz zostaje zarejestrowany.
signal player_registered(id, player)

# Sygnał emitowany, gdy gracz jest wyrejestrowywany.
signal player_deregistered(id)

# Sygnał emitowany, gdy stan gry zostaje zmieniony.
signal pause_state_changed(paused:bool)

# Słownik przechowujący informacje o obecnym graczu.
var current_player = {
	"username": ""
}

# Słownik dla serwera, przechowujący jego ustawienia.
var server_settings = {
	"port": 9001,
	"max_players": 10
}

# Słownik przechowujący informacje o obecnym stanie gry.
var current_game = {
	"started": false,
	"paused": false,
	"registered_players": {}
}


func _ready():
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


# Funkcja pozwalająca na stworzenie nowego serwera.
func create_game(port, max_players):
	# Ustawia ustawienia serwera.
	server_settings["port"] = port
	server_settings["max_players"] = max_players

	# Tworzy nową instancję ENetMultiplayerPeer.
	var peer = ENetMultiplayerPeer.new()
	var status = peer.create_server(server_settings["port"])

	# Jeśli nie udało się stworzyć serwera, to obsługuje błąd.
	if status != OK:
		_handle_error()
	else:
		multiplayer.multiplayer_peer = peer

		# Rejestruje hosta jako gracza.
		_add_registered_player(1, current_player)

		_enter_lobby()


# Funkcja pozwalaja na dołączenie do istniejącej gry.
func join_game(address, port):
	# Tworzy nową instancję ENetMultiplayerPeer.
	var peer = ENetMultiplayerPeer.new()
	var status = peer.create_client(address, port)

	# Jeśli nie udało się dołączyć do gry, to obsługuje błąd.
	if status != OK:
		_handle_error()
	else:
		multiplayer.multiplayer_peer = peer


# Funkcja pozwalająca na zmianę danych obecnego gracza.
func set_player_property(name, value):
	if current_player.has(name):
		current_player[name] = value


# Funkcja pozwalająca na zapauzowanie gry.
func set_pause_state(paused:bool):
	current_game["paused"] = paused
	pause_state_changed.emit(paused)


# Funkcja wywoływana na serwerze po rozłączeniu gracza.
func _on_player_disconnected(id):
	# Wyrejestrowuje gracza.
	_delete_deregistered_player.rpc(id)


# Funkcja wywoływana u klienta po połączeniu z serwerem.
func _on_connected():
	# Wysyła informacje o graczu do serwera.
	_register_player.rpc_id(1, current_player)


# Funkcja wywoływana u klienta po nieudanym połączeniu z serwerem.
func _on_connection_failed():
	multiplayer.multiplayer_peer = null

	_handle_error()


# Funkcja wywoływana u klienta po rozłączeniu z serwerem.
func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	current_game["registered_players"].clear()

	_handle_error()


# Funkcja zmieniająca scenę na scenę lobby.
func _enter_lobby():
	get_tree().change_scene_to_file("res://scenes/ui/lobby_menu/lobby_menu.tscn")


# TODO: Zaimplementować obsługę błędów.
func _handle_error():
	get_tree().change_scene_to_file("res://scenes/ui/play_menu/play_menu.tscn")


# Funkcja wywoływana na serwerze w celu zarejestrowania nowego gracza.
@rpc("any_peer", "reliable")
func _register_player(player):
	var id = multiplayer.get_remote_sender_id()

	# Jeśli liczba graczy jest większa niż maksymalna liczba graczy, to rozłącza nowego gracza.
	if current_game["registered_players"].size() >= server_settings["max_players"]:
		multiplayer.disconnect_peer(id)
		return

	# Jeśli gra została już rozpoczęta, to rozłącza nowego gracza.
	if current_game["started"]:
		multiplayer.disconnect_peer(id)
		return

	# Wysyłanie do nowego gracza informacji o wszystkich połączonych już graczach.
	for i in current_game["registered_players"]:
		_add_registered_player.rpc_id(id, i, current_game["registered_players"][i])

	# Wysyłanie do wszystkich połączonych graczy informacji o nowym graczu.
	_add_registered_player.rpc(id, player)

	# Wysyłanie do nowego gracza informacji o rejestracji na serwerze.
	_on_player_registered.rpc_id(id)


# Funkcja wywoływana u klienta po zarejestrowaniu go na serwerze.
@rpc("reliable")
func _on_player_registered():
	_enter_lobby()


# Funkcja dodająca nowego zarejestrowanego gracza do listy graczy.
@rpc("call_local", "reliable")
func _add_registered_player(id, player):
	current_game["registered_players"][id] = player
	player_registered.emit(id, player)


# Funkcja pozwalająca na usunięcie zderejestrowanego gracza z listy graczy.
@rpc("call_local", "reliable")
func _delete_deregistered_player(id):
	current_game["registered_players"].erase(id)
	player_deregistered.emit(id)
