extends Node
## Klasa odpowiadająca za zarządzanie stanem gry, gracza i serwera.

## Emitowany po zarejestrowaniu nowego gracza na serwerze.
signal player_registered(id: int, player: Dictionary)

## Emitowany po wyrejestrowaniu gracza z serwera.
signal player_deregistered(id: int, player: Dictionary)

## Emitowany po zmianie statusu sterowania u gracza.
signal input_status_changed(is_paused: bool)

## Emitowany u klienta po pomyślnej rejestracji na serwerze.
signal registered_successfully()

## Emitowany po rozpoczęciu gry.
signal game_started()

## Emitowany po zakończeniu gry.
signal game_ended()

## Emitowany po wystąpieniu błędu.
signal error_occured(message: String)

## Emitowany po zmianie ustawień serwera.
signal server_settings_changed()

# Przechowuje dane innych graczy z momentu rejestracji, w celu zespawnowania ich w lobby.
var lobby_data_at_registration = {}

# Przechowuje informacje o aktualnym stanie gry.
var _current_game = {
	"is_started": false,
	"is_paused": false,
	"is_input_disabled": false,
	"registered_players": {}
}

# Przechowuje dane o obecnym graczu.
var _current_player = {
	"username": "",
	"is_lecturer": false,
	"is_dead": false
}

# Przechowuje ustawienia serwera.
var _server_settings = {
	"lobby_name": "Lobby",
	"port": 9001,
	"max_players": 10,
	"max_lecturers": 3
}

# Lista atrybutów gracza, które klient ma prawo zmieniać.
var _player_fillable = ["username"]

# Lista atrybutów gracza, których klient nie może widzieć.
var _player_hidden = ["is_lecturer"]

# Predefiniowane atrybuty gracza, które nadpiszą informacje od klienta przy rejestracji.
var _player_attributes = {
	"is_lecturer": false,
	"is_dead": false
}


func _ready():
	multiplayer.peer_disconnected.connect(_delete_deregistered_player)
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


## Tworzy nowy serwer gry.
func create_lobby(lobby_name: String, port: int):
	# Ustawia parametry serwera.
	_server_settings["lobby_name"] = lobby_name
	_server_settings["port"] = port

	# Inicjalizuje serwer.
	var peer = ENetMultiplayerPeer.new()
	var status = peer.create_server(_server_settings["port"])

	if status != OK:
		_handle_error("Nie udało się nasłuchiwać na porcie " + str(_server_settings["port"]) + "!")
		return

	multiplayer.multiplayer_peer = peer

	# Oczekuje na wystartowanie serwera.
	await async_condition(
		func():
			return peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTING
	)

	if peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		_handle_error("Nie udało się uruchomić serwera!")
		return

	# Rejestruje hosta jako gracza.
	_add_registered_player(1, _current_player)
	_on_player_registered()


## Zmienia ustawienia serwera.
func change_server_settings(max_players: int, max_lecturers: int):
	if !multiplayer.is_server():
		return ERR_UNAUTHORIZED

	_server_settings["max_players"] = max_players
	_server_settings["max_lecturers"] = max_lecturers
	_update_server_settings.rpc(_server_settings)


## Wysyła informacje o ustawieniach serwera.
@rpc("call_local", "reliable")
func _update_server_settings(server_settings: Dictionary):
	if !multiplayer.is_server():
		_server_settings = server_settings
	server_settings_changed.emit()


## Dołącza do istniejącego serwera gry.
func join_lobby(address:String, port:int):
	# Tworzy klienta gry.
	var peer = ENetMultiplayerPeer.new()
	var status = peer.create_client(address, port)

	if status != OK:
		_handle_error("Nie udało się utworzyć klienta! Powód: " + error_string(status))
		return

	multiplayer.multiplayer_peer = peer

	# Oczekuje na połączenie z serwerem.
	await async_condition(
		func():
			return peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTING
	)

	if peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		_handle_error("Nie udało się połączyć z " + str(address) + ":" + str(port) + "!")
		return


## Rozpoczyna grę.
func start_game():
	if !multiplayer.is_server():
		return ERR_UNAUTHORIZED

	# Wybiera wykładowców.
	_select_lecturers()

	# Ładuje główną mapę.
	_on_game_started.rpc()

	# Przypisuje zadania.
	TaskManager.assign_tasks(1)


## Kończy grę.
func end_game():
	# Zamyka połączenie i przywraca domyślny peer.
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()

	# Resetuje stan gry.
	_current_game["is_started"] = false
	_current_game["is_paused"] = false
	_current_game["is_input_disabled"] = false
	_current_game["registered_players"].clear()

	_current_player["username"] = ""
	_current_player["is_lecturer"] = false
	_current_player["is_dead"] = false

	# Resetuje zadania.
	TaskManager.reset()

	game_ended.emit()


## Zwraca informację o grze, która jest przechowywana pod danym kluczem.
func get_current_game_key(key:String):
	if _current_game.has(key):
		return _current_game[key]

	return null


## Zwraca słownik zarejestrowanych graczy.
func get_registered_players():
	return _current_game["registered_players"]


## Zwraca informację o danym graczu, która jest przechowywana pod danym kluczem.
func get_registered_player_key(id:int, key:String):
	if _current_game["registered_players"].has(id):
		if _current_game["registered_players"][id].has(key):
			return _current_game["registered_players"][id][key]

	return null


## Zwraca ID obecnego gracza.
func get_current_player_id():
	return multiplayer.get_unique_id()


## Zwraca informację o obecnym graczu, która jest przechowywana pod danym kluczem.
func get_current_player_key(key:String):
	if _current_player.has(key):
		return _current_player[key]

	return null


## Zmienia informację o obecnym graczu, która jest przechowywana pod danym kluczem.
func set_player_key(key:String, value):
	if not key in _player_fillable:
		return ERR_UNAUTHORIZED

	if _current_player.has(key):
		_current_player[key] = value


## Zwraca informacje o ustawieniach serwera.
func get_server_settings():
	return _server_settings


## Zmienia status informacji o wyświetlaniu menu pauzy.
func set_pause_menu_status(is_paused:bool):
	_current_game["is_paused"] = is_paused
	input_status_changed.emit(!_current_game["is_paused"] && !_current_game["is_input_disabled"])


## Umożliwia zmianę statusu sterowania obecnego gracza.
func set_input_status(state:bool):
	_current_game["is_input_disabled"] = !state
	input_status_changed.emit(!_current_game["is_paused"] && !_current_game["is_input_disabled"])


## Obsługuje połączenie z serwerem u klienta.
func _on_connected():
	# Wysyła informacje o graczu do serwera w celu rejestracji.
	_register_player.rpc_id(1, _filter_player(_current_player))


## Obsługuje nieudane połączenie z serwerem u klienta.
func _on_connection_failed():
	_handle_error("Nie można połączyć się z serwerem!")
	end_game()


## Obsługuje rozłączenie z serwerem u klienta.
func _on_server_disconnected():
	_handle_error("Połączenie z serwerem zostało przerwane!")
	end_game()


## Filtruje informacje o graczu.
func _filter_player(player:Dictionary):
	var filtered_player = {}

	# Zostawia tylko atrybuty, które klient może zmieniać.
	for i in _player_fillable:
		if player.has(i):
			filtered_player[i] = player[i]

	return filtered_player


## Obsługuje błędy.
func _handle_error(message: String):
	error_occured.emit(message)


@rpc("any_peer", "reliable")
## Rejestruje gracza na serwerze.
func _register_player(player:Dictionary):
	if !multiplayer.is_server():
		return ERR_UNAUTHORIZED

	var id = multiplayer.get_remote_sender_id()

	# Wyrzuca gracza, jeśli gra już się rozpoczęła.
	if _current_game["is_started"]:
		_kick_player.rpc_id(id, "Gra już się rozpoczęła!")
		return

	# Wyrzuca gracza, jeśli przekroczono limit graczy.
	if _current_game["registered_players"].size() >= _server_settings["max_players"]:
		_kick_player.rpc_id(id, "Przekroczono limit połączeń!")
		return

	# Informuje gracza o obecnych ustawieniach serwera.
	_update_server_settings.rpc_id(id, _server_settings)

	# Informuje nowego gracza o obecnych graczach.
	for i in _current_game["registered_players"]:
		var player_in_lobby = get_tree().root.get_node("Game/Maps/Lobby/Players/" + str(i))
		var lobby_data = {
			"position": player_in_lobby.position,
			"direction_last_x": player_in_lobby.direction_last_x
		}

		_add_registered_player.rpc_id(id, i, _filter_player(_current_game["registered_players"][i]), lobby_data)

	# Informuje pozostałych graczy o nowym graczu.
	_add_registered_player.rpc(id, _filter_player(player))

	# Informuje nowego gracza o poprawnej rejestracji.
	_on_player_registered.rpc_id(id)


@rpc("reliable")
## Obsługuje pomyślną rejestrację gracza u klienta.
func _on_player_registered():
	registered_successfully.emit()


@rpc("call_local", "reliable")
## Dodaje zarejestrowanego gracza do słownika.
func _add_registered_player(id:int, player:Dictionary, lobby_data:Dictionary = {}):
	# Filtruje informacje od klienta.
	var filtered_player = _filter_player(player)

	# Dodaje predefiniowane atrybuty.
	filtered_player.merge(_player_attributes)

	# Usuwa atrybuty, których klient nie może widzieć.
	if !multiplayer.is_server():
		for i in _player_hidden:
			if filtered_player.has(i):
				filtered_player.erase(i)

	_current_game["registered_players"][id] = filtered_player

	# Zapisuje dane gracza z lobby, jeśli są dostępne.
	if lobby_data.size() > 0:
		lobby_data_at_registration[id] = lobby_data

	player_registered.emit(id, filtered_player)


## Usuwa wyrejestrowanego gracza ze słownika.
func _delete_deregistered_player(id:int):
	if _current_game["registered_players"].has(id):
		var player = _current_game["registered_players"][id]
		_current_game["registered_players"].erase(id)
		player_deregistered.emit(id, player)


@rpc("reliable")
## Wyrzuca gracza z serwera.
func _kick_player(reason: String):
	_handle_error(reason)
	end_game()


@rpc("call_local", "reliable")
## Obsługuje rozpoczęcie gry u graczy.
func _on_game_started():
	_current_game["is_started"] = true
	game_started.emit()


## Wybiera wykładowców.
func _select_lecturers():
	var available_players = get_registered_players().keys()
	# Oblicza ilość wykładowców algorytmicznie.
	var lecturers_amount = min(ceil(available_players.size() / 4.0), _server_settings["max_lecturers"])
	var lecturers = []

	for i in range(lecturers_amount):
		var id = available_players[randi() % available_players.size()]

		lecturers.append(id)
		available_players.erase(id)

	for i in lecturers:
		_current_game["registered_players"][i]["is_lecturer"] = true

		if i != 1:
			_send_lecturer_status.rpc_id(i, lecturers)
		else:
			_current_player["is_lecturer"] = true


@rpc("reliable")
## Wysyła informacje o wykładowcach.
func _send_lecturer_status(lecturers):
	for i in get_registered_players():
		_current_game["registered_players"][i]["is_lecturer"] = true if i in lecturers else false

	_current_player["is_lecturer"] = true


## Asynchronicznie czeka na warunek.
func async_condition(cond: Callable, timeout: float = 10.0) -> Error:
	timeout = Time.get_ticks_msec() + timeout * 1000
	while not cond.call():
		await get_tree().process_frame
		if Time.get_ticks_msec() > timeout:
			return ERR_TIMEOUT
	return OK
