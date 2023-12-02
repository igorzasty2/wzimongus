# Odpowiada za zarządzanie stanem gry i gracza.

extends Node

# Sygnał emitowany, gdy gracz zostaje zarejestrowany.
signal player_registered(id:int, player:Dictionary)

# Sygnał emitowany, gdy gracz jest wyrejestrowywany.
signal player_deregistered(id:int)

# Sygnał emitowany, gdy stan inputu zostanie zmieniony.
signal input_state_changed(paused:bool)


# Słownik przechowujący informacje o obecnym stanie gry.
var _current_game = {
	"started": false,
	"paused": false,
	"input_disabled": false,
	"registered_players": {}
}

# Słownik przechowujący informacje o obecnym graczu.
var _current_player = {
	"username": ""
}

# Słownik dla serwera, przechowujący jego ustawienia.
var _server_settings = {
	"port": 9001,
	"max_players": 10
}


func _ready():
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


# Funkcja pozwalająca na stworzenie nowego serwera.
func create_game(port:int, max_players:int):
	# Ustawia ustawienia serwera.
	_server_settings["port"] = port
	_server_settings["max_players"] = max_players

	# Tworzy nową instancję ENetMultiplayerPeer.
	var peer = ENetMultiplayerPeer.new()
	var status = peer.create_server(_server_settings["port"])

	if status == OK:
		multiplayer.multiplayer_peer = peer

		# Rejestruje hosta jako gracza.
		_add_registered_player(1, _current_player)

		_enter_lobby()
	else:
		_handle_error()


# Funkcja pozwalaja na dołączenie do istniejącej gry.
func join_game(address:String, port:int):
	# Tworzy nową instancję ENetMultiplayerPeer.
	var peer = ENetMultiplayerPeer.new()
	var status = peer.create_client(address, port)

	if status == OK:
		multiplayer.multiplayer_peer = peer
	else:
		_handle_error()


# Funkcja pozwalająca na rozpoczęcie gry.
func start_game():
	_current_game["started"] = true


# Funkcja pozwalająca na zakończenie gry.
func end_game():
	multiplayer.multiplayer_peer = null

	# Resetuje stan gry.
	_current_game["started"] = false
	_current_game["paused"] = false
	_current_game["input_disabled"] = false
	_current_game["registered_players"].clear()

	_handle_error()


# Funkcja pozwalająca na otrzymanie danych o obecnej grze.
func get_current_game_info(key:String):
	if _current_game.has(key):
		return _current_game[key]

	return null


# Funkcja pozwalająca na otrzymanie danych o zarejestrowanych graczach.
func get_registered_players():
	return _current_game["registered_players"]


# Funkcja pozwalająca na otrzymanie danych o pewnym zarejestrowanym graczu.
func get_registered_player_info(id:int, key:String):
	if _current_game["registered_players"].has(id):
		if _current_game["registered_players"][id].has(key):
			return _current_game["registered_players"][id][key]

	return null


# Funkcja pozwalająca na otrzymanie danych o obecnym graczu.
func get_current_player_info(key:String):
	if _current_player.has(key):
		return _current_player[key]

	return null


# Funkcja pozwalająca na zmianę danych obecnego gracza.
func set_player_info(key:String, value):
	if _current_player.has(key):
		_current_player[key] = value


# Funkcja pozwalająca na zapauzowanie gry.
func set_pause_state(paused:bool):
	_current_game["paused"] = paused
	input_state_changed.emit(!_current_game["paused"] && !_current_game["input_disabled"])


# Funkcja pozwalająca na wyłączenie sterowania.
func set_input_state(state:bool):
	_current_game["input_disabled"] = state
	input_state_changed.emit(!_current_game["paused"] && !_current_game["input_disabled"])


# Funkcja wywoływana na serwerze po rozłączeniu gracza.
func _on_player_disconnected(id:int):
	# Wyrejestrowuje gracza.
	_delete_deregistered_player.rpc(id)


# Funkcja wywoływana u klienta po połączeniu z serwerem.
func _on_connected():
	# Wysyła informacje o graczu do serwera.
	_register_player.rpc_id(1, _current_player)


# Funkcja wywoływana u klienta po nieudanym połączeniu z serwerem.
func _on_connection_failed():
	end_game()


# Funkcja wywoływana u klienta po rozłączeniu z serwerem.
func _on_server_disconnected():
	end_game()


# Funkcja zmieniająca scenę na scenę lobby.
func _enter_lobby():
	get_tree().change_scene_to_file("res://scenes/ui/lobby_menu/lobby_menu.tscn")


# TODO: Zaimplementować obsługę błędów.
func _handle_error():
	get_tree().change_scene_to_file("res://scenes/ui/start_menu/start_menu.tscn")


# Funkcja wywoływana na serwerze w celu zarejestrowania nowego gracza.
@rpc("any_peer", "reliable")
func _register_player(player:Dictionary):
	var id = multiplayer.get_remote_sender_id()

	# Jeśli liczba graczy jest większa niż maksymalna liczba graczy, to rozłącza nowego gracza.
	if _current_game["registered_players"].size() >= _server_settings["max_players"]:
		multiplayer.disconnect_peer(id)
		return

	# Jeśli gra została już rozpoczęta, to rozłącza nowego gracza.
	if _current_game["started"]:
		multiplayer.disconnect_peer(id)
		return

	# Wysyłanie do nowego gracza informacji o wszystkich połączonych już graczach.
	for i in _current_game["registered_players"]:
		_add_registered_player.rpc_id(id, i, _current_game["registered_players"][i])

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
func _add_registered_player(id:int, player:Dictionary):
	_current_game["registered_players"][id] = player
	player_registered.emit(id, player)


# Funkcja pozwalająca na usunięcie zderejestrowanego gracza z listy graczy.
@rpc("call_local", "reliable")
func _delete_deregistered_player(id:int):
	_current_game["registered_players"].erase(id)
	player_deregistered.emit(id)
