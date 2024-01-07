extends Node
## Klasa odpowiadająca za zarządzanie serwerem, grą i graczami.

## Emitowany po zarejestrowaniu nowego gracza.
signal player_registered(id: int, player: Dictionary)

## Emitowany po wyrejestrowaniu gracza.
signal player_deregistered(id: int, player: Dictionary)

## Emitowany po zmianie skina gracza.
signal skin_changed(id: int, skin: int)

## Emitowany po zmianie statusu sterowania.
signal input_status_changed(is_paused: bool)

## Emitowany u klienta po jego pomyślnej rejestracji.
signal registered_successfully()

## Emitowany po rozpoczęciu gry.
signal game_started()

## Emitowany po zakończeniu gry.
signal game_ended()

## Emitowany po wystąpieniu błędu.
signal error_occured(message: String)

## Emitowany po zabiciu gracza.
signal player_killed(id: int)

# Przechowuje informacje o aktualnym stanie gry.
## Emitowany po zmianie ustawień serwera.
signal server_settings_changed()

## Przechowuje dane innych graczy z momentu rejestracji, w celu zespawnowania ich w lobby.
var lobby_data_at_registration = {}

## Przechowuje informacje o grze.
var _current_game = {
	"is_started": false,
	"is_paused": false,
	"is_input_disabled": false,
	"is_voted": false,
	"is_vote_preselected": false,
	"registered_players": {},
	"votes": {},
	"most_voted_player": null
}

## Przechowuje zmienialne dane o obecnym graczu.
var _current_player = {
	"username": ""
}

## Przechowuje ustawienia serwera.
var _server_settings = {
	"lobby_name": "Lobby",
	"port": 9001,
	"max_players": 10,
	"max_lecturers": 3,
	"kill_cooldown": 40,
	"kill_radius": 260,
	"task_amount": 3
}

## Lista atrybutów gracza, które klient ma prawo zmieniać.
var _player_fillable = ["username"]

## Lista atrybutów gracza, których klient nie może widzieć.
var _player_hidden = ["is_lecturer"]

## Predefiniowane atrybuty gracza.
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
	_create_registered_player(1, _current_player)
	_on_player_registered()


## Zmienia ustawienia serwera.
func change_server_settings(max_players: int, max_lecturers: int, kill_cooldown: int, kill_radius: int, task_amount: int):
	if !multiplayer.is_server():
		return ERR_UNAUTHORIZED

	_server_settings["max_players"] = max_players
	_server_settings["max_lecturers"] = max_lecturers
	_server_settings["kill_cooldown"] = kill_cooldown
	_server_settings["kill_radius"] = kill_radius
	_server_settings["task_amount"] = task_amount
	_update_server_settings.rpc(_server_settings)
	server_settings_changed.emit()


## Wysyła informacje o ustawieniach serwera.
@rpc("reliable")
func _update_server_settings(server_settings: Dictionary):
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
	TaskManager.assign_tasks(_server_settings["task_amount"])


## Rozpoczyna następną rundę
func next_round():
	_current_game["is_voted"] = false
	_current_game["is_vote_preselected"] = false
	_current_game["votes"].clear()
	_current_game["most_voted_player"] = null
	GameManager.set_input_status(true)


## Kończy grę.
func end_game():
	# Zamyka połączenie i przywraca domyślny peer.
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()

	# Resetuje stan gry.
	_current_game["is_started"] = false
	_current_game["is_paused"] = false
	_current_game["is_input_disabled"] = false
	_current_game["is_voted"] = false
	_current_game["is_vote_preselected"] = false
	_current_game["registered_players"].clear()
	_current_game["votes"].clear()
	_current_game["most_voted_player"] = null

	_current_player["username"] = ""

	# Resetuje zadania.
	TaskManager.reset()

	game_ended.emit()


## Zwraca informację o grze, która jest przechowywana pod danym kluczem.
func get_current_game_key(key:String):
	if _current_game.has(key):
		return _current_game[key]


## Zmienia informację o grze, która jest przechowywana pod danym kluczem.
func set_current_game_key(key:String, value):
	if _current_game.has(key):
		_current_game[key] = value


## Dodaje głos do tablicy głosów
func add_vote(id:int, voted_by:int):
	if _current_game["votes"].has(id):
		_current_game["votes"][id].append(voted_by)
	else:
		_current_game["votes"][id] = [voted_by]


@rpc("call_local", "reliable")
## Ustawia gracza z największą ilością głosów
func set_most_voted_player(player):
	_current_game["most_voted_player"] = player


## Zwraca słownik zarejestrowanych graczy.
func get_registered_players():
	return get_current_game_key("registered_players")


## Zwraca informację o danym graczu, która jest przechowywana pod danym kluczem.
func get_registered_player_key(id:int, key:String):
	if _current_game["registered_players"].has(id) && _current_game["registered_players"][id].has(key):
		return _current_game["registered_players"][id][key]


## Zwraca ID obecnego gracza.
func get_current_player_id():
	return multiplayer.get_unique_id()


## Zwraca informację o obecnym graczu, która jest przechowywana pod danym kluczem.
func get_current_player_key(key:String):
	# Jeśli klucz jest zmienialny, szuka go w słowniku gracza.
	if key in _player_fillable && _current_player.has(key):
		return _current_player[key]

	var id = get_current_player_id()

	# W przeciwnym wypadku szuka go w słowniku zarejestrowanych graczy.
	if key in _current_game["registered_players"][id]:
		return _current_game["registered_players"][id][key]


## Zmienia informację o obecnym graczu, która jest przechowywana pod danym kluczem.
func set_current_player_key(key:String, value):
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
	input_status_changed.emit(!get_current_game_key("is_paused") && !get_current_game_key("is_input_disabled"))


## Umożliwia zmianę statusu sterowania obecnego gracza.
func set_input_status(state:bool):
	_current_game["is_input_disabled"] = !state
	input_status_changed.emit(!get_current_game_key("is_paused") && !get_current_game_key("is_input_disabled"))


## Zmienia skin obecnego gracza.
func change_skin(skin: int):
	_request_skin_change.rpc_id(1, skin)


## Przyjmuje prośbę o zmianę skina gracza.
@rpc("any_peer", "call_local", "reliable")
func _request_skin_change(skin: int):
	if !multiplayer.is_server():
		return ERR_UNAUTHORIZED

	# Jeśli gra się rozpoczęła, nie można zmienić skina.
	if get_current_game_key("is_started"):
		return

	# Jeśli skin jest już wykorzystany, nie można go użyć.
	for i in get_registered_players():
		if get_registered_player_key(i, "skin") == skin:
			return

	var id = multiplayer.get_remote_sender_id()

	_update_skin.rpc(id, skin)


## Zmienia skin gracza.
@rpc("call_local", "reliable")
func _update_skin(id: int, skin: int):
	_current_game["registered_players"][id]["skin"] = skin
	skin_changed.emit(id, skin)


## Obsługuje połączenie z serwerem u klienta.
func _on_connected():
	# Wysyła informacje o graczu do serwera w celu rejestracji.
	_register_player.rpc_id(1, _current_player)


## Obsługuje nieudane połączenie z serwerem.
func _on_connection_failed():
	_handle_error("Nie można połączyć się z serwerem!")
	end_game()


## Obsługuje rozłączenie z serwerem u klienta.
func _on_server_disconnected():
	_handle_error("Połączenie z serwerem zostało przerwane!")
	end_game()


## Filtruje słownik gracza, zostawiając tylko atrybuty, które klient może zmieniać.
func _filter_fillable(player:Dictionary):
	var filtered_player = {}

	for i in _player_fillable:
		if player.has(i):
			filtered_player[i] = player[i]

	return filtered_player


## Filtruje słownik gracza, usuwając atrybuty, których klient nie może widzieć.
func _filter_hidden(player:Dictionary):
	var filtered_player = player.duplicate()

	for i in _player_hidden:
		if filtered_player.has(i):
			filtered_player[i] = null

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
		_kick_player.rpc_id(id, "Przekroczono limit graczy!")
		return

	# Informuje gracza o obecnych ustawieniach serwera.
	_update_server_settings.rpc_id(id, _server_settings)

	# Informuje nowego gracza o obecnych graczach.
	for i in get_registered_players():
		# Pobiera dane gracza z lobby.
		var player_in_lobby = get_tree().root.get_node("Game/Maps/Lobby/Players/" + str(i))
		var lobby_data = {
			"position": player_in_lobby.position,
			"direction_last_x": player_in_lobby.direction_last_x
		}

		_add_registered_player.rpc_id(id, i, _filter_hidden(get_registered_players()[i]), lobby_data)

	# Tworzy nowego gracza.
	var registered_player = _create_registered_player(id, player)

	# Informuje wszystkich o nowym graczu.
	_add_registered_player.rpc(id, _filter_hidden(registered_player))

	# Informuje nowego gracza o poprawnej rejestracji.
	_on_player_registered.rpc_id(id)


@rpc("reliable")
## Obsługuje pomyślną rejestrację gracza u klienta.
func _on_player_registered():
	registered_successfully.emit()


## Tworzy nowego gracza.
func _create_registered_player(id:int, player:Dictionary) -> Dictionary:
	# Zostawia tylko atrybuty, które klient może zmieniać.
	var filtered_player = _filter_fillable(player)

	# Dodaje predefiniowane atrybuty.
	filtered_player.merge(_player_attributes)

	# Przypisuje skin.
	filtered_player["skin"] = _select_skin()

	_current_game["registered_players"][id] = filtered_player

	return filtered_player


## Wybiera losowy skin z puli dostępnych.
func _select_skin() -> int:
	var available_skins = []

	# Dodaje wszystkie skiny.
	for i in range(0, 12):
		available_skins.append(i)

	# Usuwa skiny, które są już wykorzystane.
	for i in _current_game["registered_players"]:
		if _current_game["registered_players"][i].has("skin"):
			available_skins.erase(_current_game["registered_players"][i]["skin"])

	# Wybiera losowy skin.
	return available_skins[randi() % available_skins.size()]


@rpc("call_local", "reliable")
## Dodaje zarejestrowanego gracza.
func _add_registered_player(id:int, player:Dictionary, lobby_data:Dictionary = {}):
	# Dodaje gracza tylko u klienta, serwer ma go już dodanego.
	if !multiplayer.is_server():
		_current_game["registered_players"][id] = player

		# Nadaje obecnemu graczowi jego domyślne atrybuty, jeśli nie są one dostępne.
		if id == get_current_player_id():
			for i in _player_hidden:
				if player.has(i) && _player_attributes.has(i):
					_current_game["registered_players"][id][i] = _player_attributes[i]

	# Zapisuje dane gracza z lobby, jeśli są dostępne.
	if lobby_data.size() > 0:
		lobby_data_at_registration[id] = lobby_data

	player_registered.emit(id, player)


## Usuwa wyrejestrowanego gracza ze słownika.
func _delete_deregistered_player(id:int):
	var registered_players = get_registered_players()

	if registered_players.has(id):
		var player = registered_players[id]
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

	for i in get_registered_players():
		_current_game["registered_players"][i]["is_lecturer"] = true if i in lecturers else false

	for i in lecturers:
		if i != 1:
			_send_lecturer_status.rpc_id(i, lecturers)


@rpc("reliable")
## Wysyła informacje o wykładowcach.
func _send_lecturer_status(lecturers:Array):
	for i in get_registered_players():
		_current_game["registered_players"][i]["is_lecturer"] = true if i in lecturers else false


## Asynchronicznie czeka na warunek.
func async_condition(cond: Callable, timeout: float = 10.0) -> Error:
	timeout = Time.get_ticks_msec() + timeout * 1000
	while not cond.call():
		await get_tree().process_frame
		if Time.get_ticks_msec() > timeout:
			return ERR_TIMEOUT
	return OK

## Zabija ofiarę
func kill(victim: int):
	_request_kill.rpc_id(1, victim)


@rpc("any_peer", "call_local", "reliable")
## Przyjmuje prośbę o zabicie gracza.
func _request_kill(victim: int):
	if !multiplayer.is_server():
		return ERR_UNAUTHORIZED
		
	# Jeśli gra się nie rozpoczęła, nie można zabić gracza.
	if !get_current_game_key("is_started"):
		return ERR_UNAVAILABLE		
		
	var me = multiplayer.get_remote_sender_id()
	if get_tree().root.get_node("Game/Maps/MainMap/Players/"+str(me)).closest_player(me) == victim:
		_kill_server.rpc(victim)


@rpc("call_local", "reliable")
## Zabija gracza i rozsyła tą informację do wszystkich.
func _kill_server(victim: int):
	_current_game["registered_players"][victim]["is_dead"] = true
	player_killed.emit(victim)
