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

## Emitowany po zaczęciu nowej rundy.
signal next_round_started()

## Emitowany po wystąpieniu błędu.
signal error_occured(message: String)

## Emitowany po zabiciu gracza.
signal player_killed(player_id: int, is_victim: bool)

## Emitowany po włączeniu sabotażu.
signal sabotage_occured()

## Emitowany po zakończeniu ładowania mapy głównej.
signal map_load_finished()

## Emitowany po zmianie ustawień serwera.
signal server_settings_changed()

## Emitowany kiedy jeden z warunków zakończenia gry jest spełniony(wszystkie zadania są zrobione, wszystkie impostory są wyeliminowane).
signal winner_determined(winning_role: Role)

## Rola gracza
enum Role {STUDENT, LECTURER}

## Komunikaty błędów.
const error_messages = {
	"ERR_LOBBY_NAME_LENGTH": "Nazwa lobby musi mieć od 3 do 16 znaków!",
	"ERR_USERNAME_LENGTH": "Nazwa użytkownika musi mieć od 3 do 16 znaków!",
	"ERR_PORT": "Nie udało się nasłuchiwać na porcie %s!",
	"ERR_SERVER": "Nie udało się uruchomić serwera!",
	"ERR_CLIENT": "Nie udało się utworzyć klienta! Powód: %s",
	"ERR_CONNECTION": "Nie udało się połączyć z %s!",
	"ERR_CONNECTION_FAILED": "Nie można połączyć się z serwerem!",
	"ERR_CONNECTION_LOST": "Połączenie z serwerem zostało przerwane!",
	"ERR_GAME_STARTED": "Gra już się rozpoczęła!",
	"ERR_MAX_PLAYERS": "Przekroczono limit graczy!",
}

## Dostępne skiny.
const skins = {
	0: {
		"name": "Alternatywka",
		"resource": "res://assets/textures/skins/alt_spritesheet.png"
	},
	1: {
		"name": "Barbie",
		"resource": "res://assets/textures/skins/barbie_spritesheet.png"
	},
	2: {
		"name": "Ecoświr",
		"resource": "res://assets/textures/skins/ecoswir_spritesheet.png"
	},
	3: {
		"name": "Femboy",
		"resource": "res://assets/textures/skins/femboy_spritesheet.png"
	},
	4: {
		"name": "Gamer",
		"resource": "res://assets/textures/skins/gamer_spritesheet.png"
	},
	5: {
		"name": "Gymbro",
		"resource": "res://assets/textures/skins/gymbro_spritesheet.png"
	},
	6: {
		"name": "Hipster",
		"resource": "res://assets/textures/skins/hipster_spritesheet.png"
	},
	7: {
		"name": "Nerd",
		"resource": "res://assets/textures/skins/nerd_spritesheet.png"
	},
	8: {
		"name": "Punk",
		"resource": "res://assets/textures/skins/punk_spritesheet.png"
	},
	9: {
		"name": "Rasta",
		"resource": "res://assets/textures/skins/rasta_spritesheet.png"
	},
	10: {
		"name": "TikToker",
		"resource": "res://assets/textures/skins/tiktoker_spritesheet.png"
	},
	11: {
		"name": "Wixiarz",
		"resource": "res://assets/textures/skins/wixiarz_spritesheet.png"
	}
}

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
	"kill_cooldown": 30,
	"sabotage_cooldown": 30,
	"kill_radius": 260,
	"task_amount": 3,
	"emergency_cooldown": 30,
	"student_light_radius": 4.0, 
	"lecturer_light_radius": 4.0,
	"voting_time": 60,
	"discussion_time": 60
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

## Okrśla czy jest zwołane alarmowe zebranie
var is_meeting_called: bool = false
## Przechowuje infromację o tym czy gra animacja tła
var is_animation_playing: bool = false
## Przechowuje pozycję animacji tła
var animation_position: float
## Przechowuje czas oczekiwania na animację - potrzebny do przejść między scenami
var wait_time
## Przechowuje teksture obecnego tła
var current_background_texture = null
## Przechowuje teksture tła przejścia
var transition_background_texture = null
## Czy scena jest włączana po raz pierwszy
var is_first_time: bool = true


func _ready():
	multiplayer.peer_disconnected.connect(_delete_deregistered_player)
	multiplayer.connected_to_server.connect(_on_connected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


## Tworzy nowy serwer gry.
func create_lobby(lobby_name: String, port: int):
	# Weryfikuje długość nazwy lobby.
	if !_verify_lobby_name_length(lobby_name):
		_handle_error(error_messages["ERR_LOBBY_NAME_LENGTH"])
		return

	# Weryfikuje długość nazwy użytkownika.
	if !_verify_username_length(_current_player["username"]):
		_handle_error(error_messages["ERR_USERNAME_LENGTH"])
		return

	# Ustawia parametry serwera.
	_server_settings["lobby_name"] = lobby_name
	_server_settings["port"] = port

	# Inicjalizuje serwer.
	var peer = ENetMultiplayerPeer.new()
	var status = peer.create_server(_server_settings["port"])

	if status != OK:
		_handle_error(error_messages["ERR_PORT"] % str(_server_settings["port"]))
		return

	multiplayer.multiplayer_peer = peer

	# Oczekuje na wystartowanie serwera.
	await async_condition(
		func():
			return peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTING
	)

	if peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		_handle_error(error_messages["ERR_SERVER"])
		return

	# Rejestruje hosta jako gracza.
	_create_registered_player(1, _current_player)
	_on_player_registered()


## Zmienia ustawienia serwera.
func change_server_settings(max_players: int, max_lecturers: int, kill_cooldown: int, sabotage_cooldown: int, kill_radius: int, task_amount: int, emergency_cooldown: int, student_light_radius: int, lecturer_light_radius: int, voting_time: int, discussion_time: int):
	if !multiplayer.is_server():
		return ERR_UNAUTHORIZED
	
	_server_settings["max_players"] = max_players
	_server_settings["max_lecturers"] = max_lecturers
	_server_settings["kill_cooldown"] = kill_cooldown
	_server_settings["kill_radius"] = kill_radius
	_server_settings["sabotage_cooldown"] = sabotage_cooldown
	_server_settings["task_amount"] = task_amount
	_server_settings["emergency_cooldown"] = emergency_cooldown
	_server_settings["lecturer_light_radius"] = lecturer_light_radius
	_server_settings["student_light_radius"] = student_light_radius
	_server_settings["voting_time"] = voting_time
	_server_settings["discussion_time"] = discussion_time
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
		_handle_error(error_messages["ERR_CLIENT"] % error_string(status))
		return

	multiplayer.multiplayer_peer = peer

	# Oczekuje na połączenie z serwerem.
	await async_condition(
		func():
			return peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTING
	)

	if peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		_handle_error(error_messages["ERR_CONNECTION"] % (str(address) + ":" + str(port)))
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

	# Resetuje system głosowania.
	_reset_votes()

	# Resetuje zadania.
	TaskManager.reset()

	game_ended.emit()


## Resetuje grę.
func reset_game():
	# Resetuje stan gry.
	_current_game["is_started"] = false

	# Nadpisuje atrybuty graczy domyślnymi atrybutami.
	for i in get_registered_players():
		_current_game["registered_players"][i].merge(_player_attributes, true)

	# Ukrywa atrybuty graczy, których klienci nie mogą widzieć.
	if !multiplayer.is_server():
		for i in get_registered_players():
			if i == get_current_player_id():
				continue

			_current_game["registered_players"][i] = _filter_hidden(_current_game["registered_players"][i])

	# Resetuje system głosowania.
	_reset_votes()

	# Resetuje zadania.
	TaskManager.reset()


## Rozpoczyna nową rundę.
func new_round():
	# Resetuje system głosowania.
	_reset_votes()
	
	next_round_started.emit()
	
	check_winning_conditions()


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


## Resetuje system głosowania.
func _reset_votes():
	_current_game["is_voted"] = false
	_current_game["is_vote_preselected"] = false
	_current_game["votes"].clear()
	_current_game["most_voted_player"] = null


## Zwraca słownik zarejestrowanych graczy.
func get_registered_players():
	return get_current_game_key("registered_players")


## Zwraca informację o danym graczu, która jest przechowywana pod danym kluczem.
func get_registered_player_key(id:int, key:String):
	if _current_game["registered_players"].has(id) && _current_game["registered_players"][id].has(key):
		return _current_game["registered_players"][id][key]


## Zwraca ID obecnego gracza.
func get_current_player_id():
	if multiplayer == null:
		return

	return multiplayer.get_unique_id()


## Zwraca informację o obecnym graczu, która jest przechowywana pod danym kluczem.
func get_current_player_key(key:String):
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
func set_pause_menu_status(is_paused: bool):
	_current_game["is_paused"] = is_paused
	emit_input_status()


## Umożliwia zmianę statusu sterowania obecnego gracza.
func set_input_disabled_status(is_input_disabled: bool):
	_current_game["is_input_disabled"] = is_input_disabled
	emit_input_status()


func emit_input_status():
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
	_handle_error(error_messages["ERR_CONNECTION_FAILED"])
	end_game()


## Obsługuje rozłączenie z serwerem u klienta.
func _on_server_disconnected():
	_handle_error(error_messages["ERR_CONNECTION_LOST"])
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

	# Wyrzuca gracza, jeśli nazwa użytkownika nie ma odpowiedniej długości.
	if !_verify_username_length(player["username"]):
		_kick_player.rpc_id(id, error_messages["ERR_USERNAME_LENGTH"])
		return

	# Wyrzuca gracza, jeśli gra już się rozpoczęła.
	if _current_game["is_started"]:
		_kick_player.rpc_id(id, error_messages["ERR_GAME_STARTED"])
		return

	# Wyrzuca gracza, jeśli przekroczono limit graczy.
	if _current_game["registered_players"].size() >= _server_settings["max_players"]:
		_kick_player.rpc_id(id, error_messages["ERR_MAX_PLAYERS"])
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

	# Nadaje unikalną nazwę użytkownika.
	filtered_player["username"] = _verify_username(filtered_player["username"])

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

		if multiplayer.is_server():
			TaskManager.remove_player_tasks(id)

			check_winning_conditions()

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


## Zabija ofiarę.
func kill_victim(victim_id: int):
	_request_victim_kill.rpc_id(1, victim_id)


@rpc("any_peer", "call_local", "reliable")
## Przyjmuje prośbę o zabicie ofiary.
func _request_victim_kill(victim_id: int):
	if !multiplayer.is_server():
		return ERR_UNAUTHORIZED

	# Jeśli gra się nie rozpoczęła, nie można zabić gracza.
	if !get_current_game_key("is_started"):
		return ERR_UNAVAILABLE

	var me = multiplayer.get_remote_sender_id()

	# Jeśli gracz nie jest wykładowcą, nie może zabić.
	if !get_registered_player_key(me, "is_lecturer"):
		return ERR_UNAUTHORIZED

	# Jeśli gracz nie jest w zasięgu, nie może zabić.
	if get_tree().root.get_node("Game/Maps/MainMap/Players/" + str(me)).closest_player(me) != victim_id:
		return ERR_UNAUTHORIZED

	_send_player_kill.rpc(victim_id, true)


## Zabija gracza.
func kill_player(player_id):
	if !multiplayer.is_server():
		return ERR_UNAUTHORIZED

	if player_id != null:
		_send_player_kill.rpc(player_id, false)


@rpc("call_local", "reliable")
## Wysyła informacje o zabiciu gracza.
func _send_player_kill(player_id: int, is_victim: bool = true):
	_current_game["registered_players"][player_id]["is_dead"] = true
	player_killed.emit(player_id, is_victim)

	if is_victim:
		check_winning_conditions()


## Sprawdza kto wygrał w tym momencie i kończy grę na korzyść wykładowcom lub crewmatom, jeżeli nikt, to nic nie robi.
func check_winning_conditions():
	if GameManager.get_current_game_key("is_started"):
		if !multiplayer.is_server():
			return ERR_UNAUTHORIZED

		if TaskManager.get_tasks_server().is_empty():
			winner_determined.emit(Role.STUDENT)
			return

		if _count_alive_lecturers() == 0:
			winner_determined.emit(Role.STUDENT)
			return

		if _count_alive_crewmates() <= _count_alive_lecturers():
			winner_determined.emit(Role.LECTURER)
			return


## Liczy żyjących wykładowców.
func _count_alive_lecturers():
	var lecturer_counter = 0
	
	for i in get_registered_players():
		if not get_registered_player_key(i, "is_dead") and get_registered_player_key(i, "is_lecturer"):
			lecturer_counter += 1

	return lecturer_counter


## Liczy żyjących crewmatów.
func _count_alive_crewmates():
	var crewmate_counter = 0
	
	for i in get_registered_players():
		if not get_registered_player_key(i, "is_dead") and not get_registered_player_key(i, "is_lecturer"):
			crewmate_counter += 1

	return crewmate_counter


## Teleportuje wszystkich graczy do miejsca spotkania - używane po rozpoczęciu przejścia na ekran ejection_screen
func teleport_players():
	var players = get_tree().root.get_node("Game/Maps/MainMap/Players").get_children()
	var meeting_positions = get_tree().root.get_node("Game/Maps/MainMap/MeetingPositions").get_children()
	
	for i in range(0, players.size()):
		if multiplayer.is_server():
			players[i].is_teleport = true
			players[i].teleport_position = meeting_positions[i].global_position


## Emituje sygnał po zakończeniu wczytywania
func main_map_load_finished():
	map_load_finished.emit()


@rpc("any_peer", "call_local", "reliable")
## Przyjmuje prośbę o włączenie sabotażu.
func request_light_sabotage():
	if not multiplayer.is_server():
		return ERR_UNAUTHORIZED

	var player_id = multiplayer.get_remote_sender_id()

	if !get_registered_player_key(player_id, "is_lecturer"):
		return ERR_UNAUTHORIZED

	activate_light_sabotage.rpc()


@rpc("call_local", "reliable")
## Emituje sygnał włączenia sabotażu.
func activate_light_sabotage():
	sabotage_occured.emit()


## Symuluje wciśnięcie klawisza w celu wywołania konkretnej akcji.
func execute_action(action_name: String):
	var event = InputEventAction.new()
	event.action = action_name
	event.pressed = true

	Input.parse_input_event(event)


## Zwraca nazwę użytkownika w formie unikalnej.
func _verify_username(username: String, idx: int = 0) -> String:
	var username_to_verify = username

	if idx > 0:
		username_to_verify += " (" + str(idx) +")"

	for i in get_registered_players():
		if get_registered_player_key(i, "username") == username_to_verify:
			return _verify_username(username, idx + 1)

	return username_to_verify


## Weryfikuje długość nazwy lobby.
func _verify_lobby_name_length(lobby_name: String) -> bool:
	return lobby_name.length() >= 3 && lobby_name.length() <= 16


## Weryfikuje długość nazwy użytkownika.
func _verify_username_length(username: String) -> bool:
	return username.length() >= 3 && username.length() <= 16
