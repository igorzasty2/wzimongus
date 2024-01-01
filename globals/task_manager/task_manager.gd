extends Node

signal tasks_change;

# Task ID bieżącego zadania.
var current_task_id = null

# TODO: Trzeba tutaj dodać minigry do słownika, aby móc przez nie iterować.
# Minigry muszą przechowywać swoją lokalizację i inne metadane potrzebne do zrobienia taska.
var _minigames = {}

# Przechowuje zadania wszystkich graczy.
var _tasks = {}
# Przechowuje zadania bieżącego gracza.
var current_player_tasks = {}


## Przypisuje zadania graczom.
func assign_tasks(task_amount):
	if !multiplayer.is_server():
		return ERR_UNAUTHORIZED

	GameManager.player_deregistered.connect(_remove_deregistered_player_tasks)
	# Oczekuje jedną klatkę na wczytanie mapy._active
	await get_tree().process_frame

	# TODO: żeby ten kod działał do końca trzeba stworzyć słownik minigier.
	_minigames = get_node("/root/Game/Maps/MainMap/Tasks").get_children()

	if multiplayer.is_server() and _tasks.is_empty():
		# Unikalny id dla każdego zadania.
		var id_counter = 0

		for i in GameManager.get_registered_players():
			if GameManager.get_registered_players()[i]["is_lecturer"]:
				continue
				
			var available_tasks = _minigames.duplicate(true)
			var tasks_dict = {}
			
			# Tworzy słownik task_amount ilości losowych zadań.
			for task_number in range(task_amount):
				#var random_key = available_tasks.keys()[randi() % available_tasks.size()]
				var random_key = randi() % available_tasks.size()
				
				tasks_dict[id_counter] = available_tasks[random_key].get_path()
				available_tasks.remove_at(random_key)

				id_counter += 1

			_tasks[i] = tasks_dict
			_send_tasks.rpc_id(i, tasks_dict)


## Oznacza zadanie jako wykonane.
func mark_task_as_complete():
	# Usuwa zadanie z listy zadań bieżącego gracza.
	var player_id = multiplayer.get_unique_id()
	current_player_tasks[current_task_id].disable_task()
	current_player_tasks.erase(current_task_id)
	
	_send_task_completion.rpc_id(1, player_id, current_task_id)
	tasks_change.emit()
	current_task_id = null


@rpc("call_local", "reliable")
## Wysyła zadania do graczy.
func _send_tasks(tasks):
	await get_tree().process_frame
	for i in tasks:
		var task = get_node(tasks[i])
		task.enable_task(i)
		current_player_tasks[i] = task
		
	tasks_change.emit()


@rpc("any_peer", "reliable")
## Wysyła infomację do serwera informujące o wykonaniu zadania.
func _send_task_completion(player_id, task_id):
	if !multiplayer.is_server():
		return ERR_UNAUTHORIZED

	# Usuwa zadanie z listy zadań na serwerze.
	_tasks[player_id].erase(task_id)

	# Usuwa gracza ze słownika zadań jeżeli wszystkie zadania są zrobione.
	if _tasks[player_id].is_empty():
		_tasks.erase(player_id)

	# TODO: ja zrobiłbym osobną funkcję check_task_winning_condition, bo ten if jeszcze jest 
	# potrzebny dla _remove_deregistered_player_tasks.
	if _tasks.is_empty():
		# TODO: Jeśli wszystkie zadania zostały wykonane oznacz, że studenci wygrali.
		pass


## Usuwa wszystkie zadania przypisane do tego gracza na serwerowej liście zadań.
func _remove_deregistered_player_tasks(id: int, player: Dictionary): 
	if !multiplayer.is_server():
		return ERR_UNAUTHORIZED
	
	_tasks.erase(id)
	
	# Czytaj _send_task_completion.
	if _tasks.is_empty():
		pass


## Resetuje zadania.
func reset():
	current_task_id = null
	_tasks.clear()
	current_player_tasks.clear()
	
	# Nie jestem pewien czy to będzie działać.
	GameManager.player_deregistered.disconnect(_remove_deregistered_player_tasks)
