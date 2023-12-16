# Zarządza stanem gry i gracza.
extends Node

# Sygnał emitowany po zarejestrowaniu gracza.
signal player_registered(id:int, player:Dictionary)

# Sygnał emitowany po wyrejestrowaniu gracza.
signal player_deregistered(id:int)

# Sygnał emitowany po zmianie stanu inputu.
signal input_status_changed(paused:bool)


signal change_map(scene)


# Zawiera informacje o aktualnym stanie gry.
var _current_game = {
	"started": false,
	"paused": false,
	"input_disabled": false,
	"registered_players": {}
}

# Przechowuje dane aktualnego gracza.
var _current_player = {
	"username": "",
	"impostor": false,
	"died": false
}

# Ustawienia serwera gry.
var _server_settings = {
	"port": 9001,
	"max_players": 10,
	"impostors": 1
}

# Lista atrybutów gracza do wypełnienia.
var _player_fillable = ["username"]

# Lista ukrytych atrybutów gracza.
var _player_hidden = ["impostor"]

# Predefiniowane atrybuty gracza.
var _player_attributes = {
	"impostor": false,
	"died": false
}


# Inicjalizuje połączenia sygnałów multiplayer.
func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


# Tworzy nowy serwer gry.
func create_game(port:int, max_players:int):
	# Ustawia parametry serwera.
	_server_settings["port"] = port
	_server_settings["max_players"] = max_players

	# Inicjalizuje serwer.
	var peer = ENetMultiplayerPeer.new()
	var status = peer.create_server(_server_settings["port"])

	if status == OK:
		multiplayer.multiplayer_peer = peer

		# Rejestruje hosta jako gracza.
		_add_registered_player(1, _current_player)

		NetworkTime.start()

		# Przechodzi do lobby.
		_enter_lobby()
	else:
		# Obsługuje błąd połączenia.
		_handle_error()


# Dołącza do istniejącej gry.
func join_game(address:String, port:int):
	# Tworzy klienta gry.
	var peer = ENetMultiplayerPeer.new()
	var status = peer.create_client(address, port)

	if status == OK:
		multiplayer.multiplayer_peer = peer

		NetworkTime.start()
	else:
		# Obsługuje błąd połączenia.
		_handle_error()


# Rozpoczyna grę.
func start_game():
	if multiplayer.is_server():
		_select_impostors()
	
	change_map.emit("res://scenes/maps/main_map/main_map.tscn")

	if multiplayer.is_server():
		# Ustawia ilość tasków u jednego gracza
		TaskManager.assign_tasks_server(1)

	_current_game["started"] = true


# Losuje morderców wśród graczy.
func _select_impostors():
	var available_players = get_registered_players().keys()
	var impostors = []

	for i in range(_server_settings["impostors"]):
		var id = available_players[randi() % available_players.size()]

		impostors.append(id)
		available_players.erase(id)

	for i in impostors:
		_current_game["registered_players"][i]["impostor"] = true
		if i != 1:
			_send_impostor_status.rpc_id(i, impostors)
		else:
			_current_player["impostor"] = true


# Ustawia status mordercy dla obecnego gracza.
@rpc("reliable")
func _send_impostor_status(impostors):
	for i in get_registered_players():
		_current_game["registered_players"][i]["impostor"] = true if i in impostors else false

	_current_player["impostor"] = true


# Kończy grę.
func end_game():
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()

	NetworkTime.stop()

	# Resetuje stan gry.
	_current_game["started"] = false
	_current_game["paused"] = false
	_current_game["input_disabled"] = false
	_current_game["registered_players"].clear()

	_current_player["username"] = ""
	_current_player["impostor"] = false
	_current_player["died"] = false

	# Obsługuje zakończenie gry.
	_handle_error()


# Zwraca klucz aktualnej gry.
func get_current_game_key(key:String):
	if _current_game.has(key):
		return _current_game[key]

	return null


# Zwraca zarejestrowanych graczy.
func get_registered_players():
	return _current_game["registered_players"]


# Zwraca klucz zarejestrowanego gracza.
func get_registered_player_key(id:int, key:String):
	if _current_game["registered_players"].has(id):
		if _current_game["registered_players"][id].has(key):
			return _current_game["registered_players"][id][key]

	return null


# Zwraca klucz obecnego gracza.
func get_current_player_key(key:String):
	if _current_player.has(key):
		return _current_player[key]

	return null


# Ustawia klucz dla obecnego gracza.
func set_player_key(key:String, value):
	if _current_player.has(key):
		_current_player[key] = value


# Zmienia status pauzy w grze.
func set_pause_status(paused:bool):
	_current_game["paused"] = paused
	input_status_changed.emit(!_current_game["paused"] && !_current_game["input_disabled"])


# Zmienia status sterowania w grze.
func set_input_status(state:bool):
	_current_game["input_disabled"] = !state
	input_status_changed.emit(!_current_game["paused"] && !_current_game["input_disabled"])


# Obsługuje rozłączenie gracza na serwerze.
func _on_player_disconnected(id:int):
	# Wyrejestrowuje gracza.
	_delete_deregistered_player.rpc(id)

# Obsługuje rozłączenie gracza na serwerze.
func _on_player_connected(id:int):
	# Rozłącza gracza, jeśli przekroczono limit połączeń.
	if _current_game["registered_players"].size() >= _server_settings["max_players"]:
		multiplayer.disconnect_peer(id)
		return

	# Rozłącza gracza, jeśli gra już się rozpoczęła.
	if _current_game["started"]:
		multiplayer.disconnect_peer(id)
		return

# Zwraca unikalny id gracza
func get_current_player_id():
	return multiplayer.get_unique_id()

# Obsługuje połączenie z serwerem u klienta.
func _on_connected():
	# Rejestruje gracza na serwerze.
	_register_player.rpc_id(1, _filter_player(_current_player))


# Obsługuje nieudane połączenie z serwerem u klienta.
func _on_connection_failed():
	end_game()


# Obsługuje rozłączenie z serwerem u klienta.
func _on_server_disconnected():
	end_game()


# Filtruje atrybuty gracza.
func _filter_player(player:Dictionary):
	var filtered_player = {}

	for i in _player_fillable:
		if player.has(i):
			filtered_player[i] = player[i]

	return filtered_player


# Zmienia scenę na scenę lobby.
func _enter_lobby():
	await get_tree().process_frame
	change_map.emit("res://scenes/maps/lobby/lobby.tscn")


# Obsługuje błędy (do implementacji).
func _handle_error():
	get_tree().change_scene_to_file("res://scenes/ui/start_menu/start_menu.tscn")


# Rejestruje gracza na serwerze.
@rpc("any_peer", "reliable")
func _register_player(player:Dictionary):
	var id = multiplayer.get_remote_sender_id()

	# Informuje nowego gracza o pozostałych graczach.
	for i in _current_game["registered_players"]:
		_add_registered_player.rpc_id(id, i, _filter_player(_current_game["registered_players"][i]))

	# Informuje pozostałych graczy o nowym graczu.
	_add_registered_player.rpc(id, _filter_player(player))

	# Informuje nowego gracza o rejestracji.
	_on_player_registered.rpc_id(id)


# Obsługuje rejestrację gracza u klienta.
@rpc("reliable")
func _on_player_registered():
	_enter_lobby()


# Dodaje zarejestrowanego gracza do listy.
@rpc("call_local", "reliable")
func _add_registered_player(id:int, player:Dictionary):
	var filtered_player = _filter_player(player)
	filtered_player.merge(_player_attributes)

	if !multiplayer.is_server():
		for i in _player_hidden:
			if filtered_player.has(i):
				filtered_player.erase(i)

	_current_game["registered_players"][id] = filtered_player
	player_registered.emit(id, filtered_player)


# Usuwa wyrejestrowanego gracza z listy.
@rpc("call_local", "reliable")
func _delete_deregistered_player(id:int):
	_current_game["registered_players"].erase(id)
	player_deregistered.emit(id)
